const router = require("express").Router();
const dashboard = require("../controllers/dashboardController");
router.get("/summary", dashboard.summary);
module.exports = router;