const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
const db=require("../config/db"), PDFDocument=require("pdfkit");
router.use(auth);
router.get("/:id/pdf",async(req,res,next)=>{
 try {
  const [rows]=await db.execute("SELECT q.*,c.name customer_name,c.email customer_email FROM quotations q LEFT JOIN customers c ON c.id=q.customer_id WHERE q.id=? LIMIT 1",[req.params.id]);
  if(!rows.length)return res.status(404).json({success:false,message:"Quotation not found."});
  const q=rows[0];res.setHeader("Content-Type","application/pdf");res.setHeader("Content-Disposition",`attachment; filename="${q.number}.pdf"`);
  const doc=new PDFDocument({size:"A4",margin:50});doc.pipe(res);
  doc.fontSize(22).fillColor("#0f172a").text("Brightloop Software").fontSize(10).fillColor("#64748b").text("Subscription Management ERP",{continued:true}).text(q.number,{align:"right"});
  doc.moveDown().fillColor("#0f172a").fontSize(16).text("QUOTATION").moveDown().fontSize(11).text(`Customer: ${q.customer_name || "-"}`).text(`Email: ${q.customer_email || "-"}`).text(`Valid until: ${q.valid_until || "-"}`).text(`Status: ${q.status}`);
  doc.moveDown().fontSize(12).text(`Total: INR ${Number(q.total || 0).toLocaleString("en-IN",{minimumFractionDigits:2})}`,{underline:true});doc.end();
 }catch(error){next(error)}
});
router.get("/",g.list("quotations"));router.post("/",g.create("quotations"));router.put("/:id",g.update("quotations"));router.delete("/:id",g.remove("quotations"));
module.exports=router;