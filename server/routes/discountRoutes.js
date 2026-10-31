const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("discounts")); router.post("/",g.create("discounts")); router.put("/:id",g.update("discounts"));
module.exports=router;