const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("roles")); router.post("/",g.create("roles")); router.put("/:id",g.update("roles"));
module.exports=router;