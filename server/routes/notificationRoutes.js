const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("notifications")); router.post("/",g.create("notifications")); router.put("/:id",g.update("notifications")); router.delete("/:id",g.remove("notifications"));
module.exports=router;