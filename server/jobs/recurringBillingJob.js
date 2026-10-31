const cron = require("node-cron");
const db = require("../config/db");
const workflowController = require("../controllers/workflowController");

async function runRecurringBilling() {
  await db.execute(
    "UPDATE invoices SET status='overdue' WHERE status IN ('issued','partially_paid') AND due_at < CURDATE()"
  );
  return workflowController.runScheduledBilling();
}

function startRecurringBillingJob() {
  if (process.env.DISABLE_CRON === "true") return null;
  return cron.schedule("0 2 * * *", async () => {
    try {
      const result = await runRecurringBilling();
      console.log(`Recurring billing completed: ${result.invoicesGenerated} invoices generated`);
    } catch (error) {
      console.error("Recurring billing scheduler check failed:", error.message);
    }
  });
}

module.exports = { runRecurringBilling, startRecurringBillingJob };
