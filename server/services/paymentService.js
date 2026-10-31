const db = require("../config/db");

exports.applyPayment = async ({ paymentId, invoiceId, amount }) => {
  await db.execute(
    "INSERT INTO payment_allocations (payment_id, invoice_id, amount) VALUES (?, ?, ?)",
    [paymentId, invoiceId, amount]
  );
  await db.execute(
    "UPDATE invoices SET amount_paid=LEAST(total, amount_paid + ?), status=CASE WHEN amount_paid + ? >= total THEN 'paid' ELSE 'partially_paid' END WHERE id=?",
    [amount, amount, invoiceId]
  );
};