const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("products")); router.post("/",g.create("products")); router.put("/:id",g.update("products")); router.delete("/:id",g.remove("products"));
module.exports=router;