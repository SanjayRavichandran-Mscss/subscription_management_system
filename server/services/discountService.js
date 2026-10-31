const Decimal = require("decimal.js");

exports.calculateDiscount = (subtotal, discount) => {
  if (!discount || discount.status !== "active") return new Decimal(0);
  if (discount.type === "percentage") return new Decimal(subtotal).mul(discount.value).div(100);
  return Decimal.min(subtotal, discount.value);
};