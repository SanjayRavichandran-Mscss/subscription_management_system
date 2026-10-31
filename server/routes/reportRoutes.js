const router=require("express").Router(), auth=require("../middleware/authMiddleware"), db=require("../config/db");
router.use(auth);
router.get("/revenue",async(req,res,next)=>{try{const [rows]=await db.execute("SELECT COALESCE(DATE_FORMAT(created_at,'%Y-%m'),DATE_FORMAT(UTC_TIMESTAMP(),'%Y-%m')) month,COALESCE(SUM(amount),0) amount FROM payments WHERE status='completed' GROUP BY month ORDER BY month DESC LIMIT 12");res.json({success:true,data:rows});}catch(e){next(e)}});
router.get("/subscriptions",async(req,res,next)=>{try{const [rows]=await db.execute("SELECT status,COUNT(*) count FROM subscriptions GROUP BY status");res.json({success:true,data:rows});}catch(e){next(e)}});
module.exports=router;