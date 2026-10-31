const db = require("../config/db");

async function count(table) {
  try { const [rows] = await db.execute(`SELECT COUNT(*) AS value FROM ${table}`); return Number(rows[0].value); }
  catch { return 0; }
}

exports.summary = async (req, res) => {
  const [customers, subscriptions, invoices, payments] = await Promise.all([count("customers"), count("subscriptions"), count("invoices"), count("payments")]);
  let revenue = 0;
  try { const [rows] = await db.execute("SELECT COALESCE(SUM(amount),0) value FROM payments WHERE status='completed'"); revenue = Number(rows[0].value); } catch {}
  res.json({ success: true, data: { customers, subscriptions, invoices, payments, revenue } });
};