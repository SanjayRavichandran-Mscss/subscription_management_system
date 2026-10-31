const db = require("../config/db");

exports.getInvoiceWithItems = async invoiceId => {
  const [[invoiceRows], [items]] = await Promise.all([
    db.execute("SELECT * FROM invoices WHERE id=? LIMIT 1", [invoiceId]),
    db.execute("SELECT * FROM invoice_items WHERE invoice_id=? ORDER BY id", [invoiceId])
  ]);
  return invoiceRows[0] ? { ...invoiceRows[0], items } : null;
};