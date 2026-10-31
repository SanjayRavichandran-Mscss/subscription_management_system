require("dotenv").config({ quiet: true });

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const db = require("./config/db");

const app = express();
app.disable("x-powered-by");
app.use(helmet());
app.use(cors({ origin: process.env.CLIENT_URL || "http://localhost:5173" }));
app.use(express.json({ limit: "1mb" }));
app.use("/api/auth", rateLimit({ windowMs: 15 * 60 * 1000, limit: 30, standardHeaders: "draft-7" }));

app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/dashboard", require("./routes/dashboardRoutes"));

const resources = {
  customers: "customerRoutes", users: "userRoutes", roles: "roleRoutes",
  products: "productRoutes", categories: "categoryRoutes", variants: "variantRoutes",
  plans: "planRoutes", quotations: "quotationRoutes", subscriptions: "subscriptionRoutes",
  "billing-runs": "billingRoutes", invoices: "invoiceRoutes", taxes: "taxRoutes",
  discounts: "discountRoutes", payments: "paymentRoutes", refunds: "refundRoutes",
  notifications: "notificationRoutes", reports: "reportRoutes", settings: "settingsRoutes"
};
Object.entries(resources).forEach(([path, route]) => app.use(`/api/${path}`, require(`./routes/${route}`)));
app.use("/api/test", require("./routes/testRoutes"));

app.use((req, res) => res.status(404).json({ success: false, message: "API route not found" }));
app.use((error, req, res, next) => {
  console.error(error);
  res.status(error.status || 500).json({ success: false, message: error.status ? error.message : "Internal server error" });
});

const PORT = Number(process.env.PORT) || 5000;
async function start() {
  await db.query("SELECT 1");
  app.listen(PORT, () => console.log(`Brightloop API listening on port ${PORT}`));
}
start().catch(error => { console.error("Unable to start API:", error.message); process.exit(1); });
