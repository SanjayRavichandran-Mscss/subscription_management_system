const db = require("../config/db");
const Decimal = require("decimal.js");

const money = value => new Decimal(value || 0).toDecimalPlaces(2).toString();

exports.subscriptionAction = async (req, res, next) => {
  const allowed = new Set(["activate","pause","cancel","renew","expire"]);
  const action = req.params.action;
  if (!allowed.has(action)) return res.status(400).json({ success: false, message: "Unsupported subscription action." });
  const status = { activate:"active", pause:"paused", cancel:"cancelled", renew:"active", expire:"expired" }[action];
  try {
    const [result] = await db.execute(
      `UPDATE subscriptions SET status=?, next_billing_at=CASE WHEN ?='renew' THEN COALESCE(DATE_ADD(next_billing_at, INTERVAL 1 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 MONTH)) ELSE next_billing_at END WHERE id=?`,
      [status, action, req.params.id]
    );
    if (!result.affectedRows) return res.status(404).json({ success: false, message: "Subscription not found." });
    await db.execute("INSERT INTO audit_logs (user_id,action,entity_type,entity_id,new_values) VALUES (?, ?, 'subscription', ?, JSON_OBJECT('status', ?))", [req.user.id, action.toUpperCase(), req.params.id, status]);
    res.json({ success: true, data: { status } });
  } catch (error) { next(error); }
};

exports.runBilling = async (req, res, next) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [runRows] = await connection.execute(
      "INSERT INTO billing_runs (period_start,period_end,status) VALUES (?, ?, 'running')",
      [req.body.period_start || new Date().toISOString().slice(0,10), req.body.period_end || new Date().toISOString().slice(0,10)]
    );
    const [subscriptions] = await connection.execute(
      "SELECT * FROM subscriptions WHERE status='active' AND next_billing_at <= ? FOR UPDATE",
      [req.body.period_end || new Date().toISOString().slice(0,10)]
    );
    let generated = 0;
    for (const subscription of subscriptions) {
      const subtotal = new Decimal(subscription.unit_price).mul(subscription.quantity || 1);
      const tax = subtotal.mul(subscription.tax_rate || 0).div(100);
      const discount = new Decimal(subscription.discount_amount || 0);
      const total = subtotal.add(tax).sub(discount).max(0);
      const invoiceNumber = `INV-${Date.now()}-${subscription.id}`;
      try {
        const [invoice] = await connection.execute(
          "INSERT INTO invoices (number,customer_id,subscription_id,billing_run_id,subtotal,tax_amount,discount_amount,total,status,issued_at,due_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'issued', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY))",
          [invoiceNumber, subscription.customer_id, subscription.id, runRows.insertId, money(subtotal), money(tax), money(discount), money(total)]
        );
        await connection.execute(
          "INSERT INTO invoice_items (invoice_id,description,quantity,unit_price,tax_rate,discount_amount,line_total) VALUES (?, ?, ?, ?, ?, ?, ?)",
          [invoice.insertId, `Subscription ${subscription.number}`, subscription.quantity, subscription.unit_price, subscription.tax_rate || 0, discount, money(subtotal.sub(discount))]
        );
        await connection.execute("UPDATE subscriptions SET next_billing_at=DATE_ADD(next_billing_at, INTERVAL 1 MONTH) WHERE id=?", [subscription.id]);
        generated++;
      } catch (error) {
        if (error.code !== "ER_DUP_ENTRY") throw error;
      }
    }
    await connection.execute("UPDATE billing_runs SET status='completed', invoices_generated=? WHERE id=?", [generated, runRows.insertId]);
    await connection.commit();
    res.status(201).json({ success: true, data: { billingRunId: runRows.insertId, invoicesGenerated: generated } });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally { connection.release(); }
};

exports.recordPayment = async (req, res, next) => {
  const amount = new Decimal(req.body.amount || 0);
  if (amount.lte(0)) return res.status(400).json({ success: false, message: "Payment amount must be greater than zero." });
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const reference = req.body.reference || `PAY-${Date.now()}`;
    const [payment] = await connection.execute(
      "INSERT INTO payments (reference,customer_id,invoice_id,amount,method,status,paid_at) VALUES (?, ?, ?, ?, ?, 'completed', UTC_TIMESTAMP())",
      [reference, req.body.customer_id, req.body.invoice_id || null, money(amount), req.body.method || "bank_transfer"]
    );
    let allocated = new Decimal(0);
    if (req.body.invoice_id) {
      const [invoices] = await connection.execute("SELECT total,amount_paid FROM invoices WHERE id=? AND customer_id=? FOR UPDATE", [req.body.invoice_id, req.body.customer_id]);
      if (!invoices.length) throw Object.assign(new Error("Invoice does not belong to this customer."), { status: 400 });
      allocated = Decimal.min(amount, new Decimal(invoices[0].total).sub(invoices[0].amount_paid));
      if (allocated.gt(0)) await connection.execute("INSERT INTO payment_allocations (payment_id,invoice_id,amount) VALUES (?, ?, ?)", [payment.insertId, req.body.invoice_id, money(allocated)]);
      const paid = new Decimal(invoices[0].amount_paid).add(allocated);
      const status = paid.gte(invoices[0].total) ? "paid" : paid.gt(0) ? "partially_paid" : "issued";
      await connection.execute("UPDATE invoices SET amount_paid=?,status=? WHERE id=?", [money(paid), status, req.body.invoice_id]);
    }
    await connection.commit();
    res.status(201).json({ success: true, data: { paymentId: payment.insertId, allocated: money(allocated) } });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally { connection.release(); }
};

exports.processRefund = async (req, res, next) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [payments] = await connection.execute("SELECT * FROM payments WHERE id=? FOR UPDATE", [req.body.payment_id]);
    if (!payments.length) throw Object.assign(new Error("Payment not found."), { status: 404 });
    const [refunds] = await connection.execute("SELECT COALESCE(SUM(amount),0) total FROM refunds WHERE payment_id=? AND status!='rejected'", [req.body.payment_id]);
    const refundable = new Decimal(payments[0].amount).sub(refunds[0].total);
    const amount = new Decimal(req.body.amount || refundable);
    if (amount.lte(0) || amount.gt(refundable)) throw Object.assign(new Error("Refund amount exceeds refundable balance."), { status: 400 });
    const [result] = await connection.execute("INSERT INTO refunds (payment_id,amount,reason,status) VALUES (?, ?, ?, 'completed')", [req.body.payment_id, money(amount), req.body.reason || null]);
    if (amount.gte(refundable)) await connection.execute("UPDATE payments SET status='refunded' WHERE id=?", [req.body.payment_id]);
    await connection.commit();
    res.status(201).json({ success: true, data: { refundId: result.insertId } });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally { connection.release(); }
};

exports.runScheduledBilling = async () => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [run] = await connection.execute(
      "INSERT INTO billing_runs (period_start,period_end,status) VALUES (CURDATE(),CURDATE(),'running')"
    );
    const [subscriptions] = await connection.execute(
      "SELECT * FROM subscriptions WHERE status='active' AND next_billing_at<=CURDATE() FOR UPDATE"
    );
    let generated = 0;
    for (const subscription of subscriptions) {
      const subtotal = new Decimal(subscription.unit_price).mul(subscription.quantity || 1);
      const total = subtotal.max(0);
      const number = `INV-${Date.now()}-${subscription.id}`;
      try {
        const [invoice] = await connection.execute(
          "INSERT INTO invoices (number,customer_id,subscription_id,billing_run_id,subtotal,total,status,issued_at,due_at) VALUES (?, ?, ?, ?, ?, ?, 'issued', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY))",
          [number, subscription.customer_id, subscription.id, run.insertId, money(subtotal), money(total)]
        );
        await connection.execute(
          "INSERT INTO invoice_items (invoice_id,description,quantity,unit_price,line_total) VALUES (?, ?, ?, ?, ?)",
          [invoice.insertId, `Subscription ${subscription.number}`, subscription.quantity, subscription.unit_price, money(subtotal)]
        );
        await connection.execute("UPDATE subscriptions SET next_billing_at=DATE_ADD(next_billing_at, INTERVAL 1 MONTH) WHERE id=?", [subscription.id]);
        generated++;
      } catch (error) {
        if (error.code !== "ER_DUP_ENTRY") throw error;
      }
    }
    await connection.execute("UPDATE billing_runs SET status='completed',invoices_generated=? WHERE id=?", [generated, run.insertId]);
    await connection.commit();
    return { billingRunId: run.insertId, invoicesGenerated: generated };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};
