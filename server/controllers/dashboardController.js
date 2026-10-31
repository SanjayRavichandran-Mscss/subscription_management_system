const db = require("../config/db");

async function count(table) {
  try { const [rows] = await db.execute(`SELECT COUNT(*) AS value FROM ${table}`); return Number(rows[0].value); }
  catch { return 0; }
}

exports.summary = async (req, res) => {
  const [customers, subscriptions, invoices, payments] = await Promise.all([count("customers"), count("subscriptions"), count("invoices"), count("payments")]);
  let revenue = 0, outstanding = 0;
  try {
    const [[financials]] = await db.execute(`SELECT
      COALESCE(SUM(CASE WHEN status='completed' THEN amount ELSE 0 END),0) revenue,
      COALESCE(SUM(CASE WHEN status IN ('issued','partially_paid','overdue') THEN total-amount_paid ELSE 0 END),0) outstanding
      FROM payments LEFT JOIN invoices ON invoices.id=payments.invoice_id`);
    revenue = Number(financials.revenue || 0);
  } catch {}
  try {
    const [[invoiceBalance]] = await db.execute("SELECT COALESCE(SUM(total-amount_paid),0) value FROM invoices WHERE status IN ('issued','partially_paid','overdue')");
    outstanding = Number(invoiceBalance.value || 0);
  } catch {}
  let recentPayments = [];
  try {
    const [rows] = await db.execute(`SELECT p.reference,c.name customer,p.amount,p.status,p.method,p.paid_at
      FROM payments p JOIN customers c ON c.id=p.customer_id ORDER BY p.created_at DESC LIMIT 6`);
    recentPayments = rows;
  } catch {}
  res.json({ success: true, data: { customers, subscriptions, invoices, payments, revenue, outstanding, recentPayments } });
};