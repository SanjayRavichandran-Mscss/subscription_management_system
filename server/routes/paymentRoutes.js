const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("payments")); router.post("/",g.create("payments")); router.put("/:id",g.update("payments"));
module.exports=router;