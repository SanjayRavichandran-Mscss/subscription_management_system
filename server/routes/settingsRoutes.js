const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("settings")); router.post("/",g.create("settings")); router.put("/:id",g.update("settings")); router.delete("/:id",g.remove("settings"));
module.exports=router;