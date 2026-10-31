const router=require("express").Router(), auth=require("../middleware/authMiddleware"), g=require("../controllers/genericController");
const db=require("../config/db"), PDFDocument=require("pdfkit");
router.use(auth);
router.get("/:id/pdf",async(req,res,next)=>{
 try {
  const [rows]=await db.execute("SELECT * FROM invoices WHERE id=? LIMIT 1",[req.params.id]);
  if(!rows.length) return res.status(404).json({success:false,message:"Invoice not found."});
  res.setHeader("Content-Type","application/pdf"); res.setHeader("Content-Disposition",`attachment; filename="${rows[0].number}.pdf"`);
  const doc=new PDFDocument({margin:50}); doc.pipe(res);
  doc.fontSize(20).text("Brightloop Software",{continued:true}).fontSize(12).text(`Invoice ${rows[0].number}`,{align:"right"});
  doc.moveDown().text(`Status: ${rows[0].status}`).text(`Issued: ${rows[0].issued_at || "-"}`).text(`Due: ${rows[0].due_at || "-"}`);
  doc.moveDown().text(`Subtotal: ${rows[0].subtotal}`).text(`Tax: ${rows[0].tax_amount}`).text(`Discount: ${rows[0].discount_amount}`).text(`Total: ${rows[0].total}`,{underline:true});
  doc.end();
 } catch(error){next(error)}
});
router.post("/:id/:action",async(req,res,next)=>{
 try {
  const statuses={confirm:"issued",cancel:"void"};
  if(!statuses[req.params.action])return res.status(400).json({success:false,message:"Unsupported invoice action."});
  await db.execute("UPDATE invoices SET status=? WHERE id=?", [statuses[req.params.action],req.params.id]);
  await db.execute("UPDATE invoices SET status='overdue' WHERE status IN ('issued','partially_paid') AND due_at < CURDATE()");
  res.json({success:true,status:statuses[req.params.action]});
 }catch(error){next(error)}
});
router.get("/",g.list("invoices")); router.post("/",g.create("invoices")); router.put("/:id",g.update("invoices")); router.delete("/:id",g.remove("invoices"));
module.exports=router;