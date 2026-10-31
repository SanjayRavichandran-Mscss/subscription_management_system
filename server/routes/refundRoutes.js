const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("refunds")); router.post("/",g.create("refunds")); router.put("/:id",g.update("refunds"));
module.exports=router;