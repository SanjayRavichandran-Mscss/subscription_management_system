const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
router.use(auth); router.get("/",g.list("customers")); router.post("/",g.create("customers")); router.put("/:id",g.update("customers"));
module.exports=router;