const Decimal = require("decimal.js");

exports.calculateTax = (amount, rate) => new Decimal(amount || 0).mul(rate || 0).div(100).toDecimalPlaces(2);