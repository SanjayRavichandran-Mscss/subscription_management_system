const db = require("../config/db");

const cycleDays = { daily: 1, weekly: 7, monthly: 30, quarterly: 90, yearly: 365 };

exports.nextBillingDate = async subscriptionId => {
  const [rows] = await db.execute(
    `SELECT s.next_billing_at, p.billing_cycle, p.billing_interval
     FROM subscriptions s LEFT JOIN subscription_plans p ON p.id=s.plan_id WHERE s.id=?`,
    [subscriptionId]
  );
  if (!rows.length) return null;
  const base = rows[0].next_billing_at ? new Date(rows[0].next_billing_at) : new Date();
  const days = (cycleDays[rows[0].billing_cycle] || 30) * Number(rows[0].billing_interval || 1);
  base.setDate(base.getDate() + days);
  return base.toISOString().slice(0, 10);
};