const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("invoices")); router.post("/",g.create("invoices")); router.put("/:id",g.update("invoices"));
module.exports=router;