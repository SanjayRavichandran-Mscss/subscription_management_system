import "./invoice-template.css";

export default function InvoiceTemplate({ invoice = {}, customer = {}, items = [] }) {
  const formatMoney = value => Number(value || 0).toLocaleString("en-IN", { style: "currency", currency: "INR" });
  return (
    <article className="invoice-document">
      <header>
        <div><h1>Brightloop Software</h1><p>Subscription Management ERP</p></div>
        <div className="invoice-title"><h2>Invoice</h2><strong>{invoice.number || "DRAFT"}</strong></div>
      </header>
      <section className="invoice-parties">
        <div><span>Bill to</span><strong>{customer.name || "-"}</strong><p>{customer.company || ""}</p><p>{customer.email || ""}</p></div>
        <dl><div><dt>Status</dt><dd>{invoice.status || "draft"}</dd></div><div><dt>Issued</dt><dd>{invoice.issued_at || "-"}</dd></div><div><dt>Due</dt><dd>{invoice.due_at || "-"}</dd></div></dl>
      </section>
      <table><thead><tr><th>Description</th><th>Quantity</th><th>Rate</th><th>Amount</th></tr></thead><tbody>{items.map((item,index)=><tr key={item.id || index}><td>{item.description}</td><td>{item.quantity}</td><td>{formatMoney(item.unit_price)}</td><td>{formatMoney(item.line_total)}</td></tr>)}</tbody></table>
      <section className="invoice-totals"><dl><div><dt>Subtotal</dt><dd>{formatMoney(invoice.subtotal)}</dd></div><div><dt>Tax</dt><dd>{formatMoney(invoice.tax_amount)}</dd></div><div><dt>Discount</dt><dd>{formatMoney(invoice.discount_amount)}</dd></div><div className="grand-total"><dt>Total</dt><dd>{formatMoney(invoice.total)}</dd></div></dl></section>
    </article>
  );
}
