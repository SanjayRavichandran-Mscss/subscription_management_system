const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("users")); router.post("/",g.create("users")); router.put("/:id",g.update("users")); router.delete("/:id",g.remove("users"));
module.exports=router;