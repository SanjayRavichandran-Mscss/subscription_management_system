const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("taxes")); router.post("/",g.create("taxes")); router.put("/:id",g.update("taxes"));
module.exports=router;