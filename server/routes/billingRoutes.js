const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("billing_runs")); router.post("/",g.create("billing_runs")); router.put("/:id",g.update("billing_runs")); router.delete("/:id",g.remove("billing_runs"));
module.exports=router;