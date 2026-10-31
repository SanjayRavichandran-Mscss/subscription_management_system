const db = require("../config/db");

exports.createRun = async ({ periodStart, periodEnd }) => {
  const [subscriptions] = await db.execute(
    "SELECT s.id, s.customer_id, s.unit_price, s.quantity FROM subscriptions s WHERE s.status='active' AND (s.next_billing_at IS NULL OR s.next_billing_at <= ?)",
    [periodEnd]
  );
  const [result] = await db.execute(
    "INSERT INTO billing_runs (period_start, period_end, status, invoices_generated) VALUES (?, ?, 'completed', ?)",
    [periodStart, periodEnd, subscriptions.length]
  );
  return { runId: result.insertId, subscriptionsProcessed: subscriptions.length };
};