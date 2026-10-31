const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("categories")); router.post("/",g.create("categories")); router.put("/:id",g.update("categories")); router.delete("/:id",g.remove("categories"));
module.exports=router;