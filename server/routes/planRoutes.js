const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("subscription_plans")); router.post("/",g.create("subscription_plans")); router.put("/:id",g.update("subscription_plans")); router.delete("/:id",g.remove("subscription_plans"));
module.exports=router;