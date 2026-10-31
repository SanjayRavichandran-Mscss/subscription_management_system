const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("quotations")); router.post("/",g.create("quotations")); router.put("/:id",g.update("quotations"));
module.exports=router;