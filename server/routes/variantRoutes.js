const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("product_variants")); router.post("/",g.create("product_variants")); router.put("/:id",g.update("product_variants")); router.delete("/:id",g.remove("product_variants"));
module.exports=router;