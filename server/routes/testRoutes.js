const express = require("express");
const router = express.Router();

const { testConnection } = require("../controllers/testController");

router.get("/test", testConnection);

module.exports = router;