const router = require("express").Router();
const auth = require("../middleware/authMiddleware");
const permission = require("../middleware/permissionMiddleware");
const workflow = require("../controllers/workflowController");

router.use(auth);
router.post("/subscriptions/:id/:action", permission("subscription.manage"), workflow.subscriptionAction);
router.post("/billing/run", permission("invoice.confirm"), workflow.runBilling);
router.post("/payments", permission("payment.manage"), workflow.recordPayment);
router.post("/refunds", permission("refund.manage"), workflow.processRefund);

module.exports = router;
