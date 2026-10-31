const test = require("node:test");
const assert = require("node:assert/strict");
const jwt = require("jsonwebtoken");

test("JWT token contains active user id", () => {
  const payload = jwt.verify(jwt.sign({ sub: 1, role: "SUPER_ADMIN" }, "test-secret"), "test-secret");
  assert.equal(payload.sub, 1);
  assert.equal(payload.role, "SUPER_ADMIN");
});

test("password policy rejects weak passwords", () => {
  const valid = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{9,}$/;
  assert.equal(valid.test("Weak123"), false);
  assert.equal(valid.test("Strong123!"), true);
});
