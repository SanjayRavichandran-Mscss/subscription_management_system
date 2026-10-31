const db = require("../config/db");

const allowedTables = new Set(["customers","users","roles","categories","products","product_variants","subscription_plans","quotations","subscriptions","billing_runs","invoices","taxes","discounts","payments","refunds","notifications","settings"]);

const referenceTables = {
  user_id: "users", customer_id: "customers", role_id: "roles", parent_id: null,
  category_id: "categories", product_id: "products", plan_id: "subscription_plans",
  quotation_id: "quotations", subscription_id: "subscriptions", billing_run_id: "billing_runs",
  invoice_id: "invoices", payment_id: "payments", created_by: "users"
};

function cleanValue(field, value, column) {
  if (value === "" || value === null || value === undefined) return "";
  if (/^enum\(/i.test(column.Type)) {
    const allowed = [...String(column.Type).matchAll(/'((?:[^'\\]|\\.)*)'/g)]
      .map(match => match[1].replace(/\\'/g, "'"));
    const normalized = String(value).trim().toLowerCase().replace(/[\s-]+/g, "_");
    const aliases = { "credit_card": "card", "creditcard": "card", "net_banking": "bank_transfer", "bank": "bank_transfer", "google_pay": "upi", "phone_pe": "upi", "cheque": "cheque" };
    const candidate = aliases[normalized] || normalized;
    if (!allowed.includes(candidate)) return `__INVALID_ENUM__${candidate}`;
    return candidate;
  }
  if (/^(date|datetime|timestamp)/i.test(column.Type) && typeof value === "string") {
    const isoMatch = value.match(/^(\d{4}-\d{2}-\d{2})(?:T|$)/);
    if (isoMatch) return isoMatch[1];
  }
  return value;
}

async function cleanReferences(values) {
  for (const [field, value] of Object.entries(values)) {
    if (!referenceTables[field] || value === "") continue;
    if (referenceTables[field] === null) continue;
    const numericId = Number(value);
    if (!Number.isInteger(numericId) || numericId < 1) {
      delete values[field];
      continue;
    }

    function invalidEnum(values) {
      const field = Object.keys(values).find(key => String(values[key]).startsWith("__INVALID_ENUM__"));
      return field ? { field, value: String(values[field]).replace("__INVALID_ENUM__", "") } : null;
    }
    const [rows] = await db.execute(`SELECT id FROM \`${referenceTables[field]}\` WHERE id=? LIMIT 1`, [numericId]);
    if (!rows.length) delete values[field];
  }
}

exports.list = table => async (req, res, next) => {
  if (!allowedTables.has(table)) return next(Object.assign(new Error("Resource unavailable"), { status: 404 }));
  try {
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, Number(req.query.limit) || 20));
    const offset = (page - 1) * limit;
    const search = String(req.query.search || "").trim();
    const [columns] = await db.execute(`SHOW COLUMNS FROM \`${table}\``);
    const textColumns = columns.filter(c => /char|text/i.test(c.Type)).map(c => c.Field);
    let where = "", params = [];
    if (req.user?.role === "CUSTOMER") {
      if (table === "customers") { where = " WHERE user_id=(SELECT id FROM users WHERE id=?)"; params = [req.user.id]; }
      if (["subscriptions","invoices","payments","refunds","quotations"].includes(table)) {
        const fk = table === "subscriptions" ? "customer_id" : (table === "refunds" ? "payment_id" : "customer_id");
        if (fk === "payment_id") where = " WHERE payment_id IN (SELECT id FROM payments WHERE customer_id=(SELECT c.id FROM customers c WHERE c.user_id=?))";
        else where = ` WHERE \`${fk}\`=(SELECT id FROM customers WHERE user_id=? LIMIT 1)`;
        params = [req.user.id];
      }
    }
    if (search && textColumns.length) {
      where += `${where ? " AND" : " WHERE"} (${textColumns.map(c => `\`${c}\` LIKE ?`).join(" OR ")})`;
      params = [...params, ...textColumns.map(() => `%${search}%`)];
    }
    const [countRows] = await db.execute(`SELECT COUNT(*) total FROM \`${table}\`${where}`, params);
    const allowedSortFields = new Set(columns.map(column => column.Field));
    const sort = allowedSortFields.has(String(req.query.sort || "")) ? String(req.query.sort) : "id";
    const direction = String(req.query.direction || "desc").toLowerCase() === "asc" ? "ASC" : "DESC";
    const [rows] = await db.execute(`SELECT * FROM \`${table}\`${where} ORDER BY \`${sort}\` ${direction} LIMIT ${limit} OFFSET ${offset}`, params);
    res.json({ success: true, data: rows, pagination: { page, limit, total: countRows[0].total } });
  } catch (error) { next(error); }
};

exports.create = table => async (req, res, next) => {
  if (table === "users" && !["SUPER_ADMIN","ADMIN"].includes(req.user?.role)) return res.status(403).json({success:false,message:"Only administrators can create users."});
  try {
    const [columns] = await db.execute(`SHOW COLUMNS FROM \`${table}\``);
    const writable = columns.map(c => c.Field).filter(c => !["id","created_at","updated_at"].includes(c));
    const values = {};
    writable.forEach(field => {
      const column = columns.find(item => item.Field === field);
      const value = cleanValue(field, req.body[field], column || { Type: "" });
      if (req.body[field] !== undefined && value !== "") values[field] = value;
    });
    await cleanReferences(values);
    const invalid = invalidEnum(values);
    if (invalid) return res.status(422).json({ success: false, message: `${invalid.field.replaceAll("_", " ")} must be one of the available options.` });
    const requiredColumns = columns.filter(column => column.Null === "NO" &&
      !["id","created_at","updated_at"].includes(column.Field) && column.Default === null && req.body[column.Field] === undefined);
    if (requiredColumns.length) return res.status(422).json({
      success: false,
      message: `Required fields: ${requiredColumns.map(column => column.Field.replaceAll("_", " ")).join(", ")}`
    });
    const keys = Object.keys(values);
    if (!keys.length) return res.status(400).json({ success: false, message: "No valid fields supplied." });
    const [result] = await db.execute(`INSERT INTO \`${table}\` (${keys.map(k => `\`${k}\``).join(",")}) VALUES (${keys.map(() => "?").join(",")})`, keys.map(k => values[k]));
    res.status(201).json({ success: true, data: { id: result.insertId, ...values } });
  } catch (error) { next(error); }
};

exports.update = table => async (req, res, next) => {
  if (table === "users" && !["SUPER_ADMIN","ADMIN"].includes(req.user?.role)) return res.status(403).json({success:false,message:"Only administrators can update users."});
  try {
    const [columns] = await db.execute(`SHOW COLUMNS FROM \`${table}\``);
    const writable = columns.map(c => c.Field).filter(c => !["id","created_at","updated_at"].includes(c));
    const keys = writable.filter(k => req.body[k] !== undefined);
    if (!keys.length) return res.status(400).json({ success: false, message: "No valid fields supplied." });
    const values = {};
    keys.forEach(field => {
      const column = columns.find(item => item.Field === field);
      values[field] = cleanValue(field, req.body[field], column || { Type: "" });
    });
    await cleanReferences(values);
    const invalid = invalidEnum(values);
    if (invalid) return res.status(422).json({ success: false, message: `${invalid.field.replaceAll("_", " ")} must be one of the available options.` });
    const validKeys = Object.keys(values);
    if (!validKeys.length) return res.status(400).json({ success: false, message: "The supplied related record does not exist." });
    await db.execute(`UPDATE \`${table}\` SET ${validKeys.map(k => `\`${k}\`=?`).join(",")}, updated_at=UTC_TIMESTAMP() WHERE id=?`, [...validKeys.map(k => values[k] || null), req.params.id]);
    res.json({ success: true });
  } catch (error) { next(error); }
};

exports.remove = table => async (req, res, next) => {
  if (table === "users" && !["SUPER_ADMIN","ADMIN"].includes(req.user?.role)) return res.status(403).json({success:false,message:"Only administrators can delete users."});
  try {
    const [result] = await db.execute(`DELETE FROM \`${table}\` WHERE id=?`, [req.params.id]);
    if (!result.affectedRows) return res.status(404).json({ success: false, message: "Record not found." });
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
};
