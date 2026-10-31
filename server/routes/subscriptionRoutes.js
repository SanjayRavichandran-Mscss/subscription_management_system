const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("subscriptions")); router.post("/",g.create("subscriptions")); router.put("/:id",g.update("subscriptions"));
module.exports=router;