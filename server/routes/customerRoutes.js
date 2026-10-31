const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
const audit=require("../middleware/auditMiddleware");
router.use(auth,audit()); router.get("/",g.list("customers")); router.post("/",g.create("customers")); router.put("/:id",g.update("customers")); router.delete("/:id",g.remove("customers"));
module.exports=router;