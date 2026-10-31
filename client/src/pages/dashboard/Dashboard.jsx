import { useEffect, useState } from "react";
import { AlertCircle, ArrowUpRight, CreditCard, DollarSign, Receipt, RefreshCcw, TrendingUp, Users } from "lucide-react";
import toast from "react-hot-toast";
import api from "../../services/api";
import PageHeader from "../../components/layout/PageHeader";

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get("/dashboard/summary")
      .then(({ data }) => setStats(data.data))
      .catch(error => toast.error(error.response?.data?.message || "Unable to load dashboard"))
      .finally(() => setLoading(false));
  }, []);

  const cards = [
    ["Active customers", stats?.customers ?? 0, Users, "blue"],
    ["Subscriptions", stats?.subscriptions ?? 0, RefreshCcw, "violet"],
    ["Invoices issued", stats?.invoices ?? 0, Receipt, "amber"],
    ["Collected revenue", `₹${Number(stats?.revenue ?? 0).toLocaleString("en-IN")}`, DollarSign, "emerald"]
  ];

  return (
    <section>
      <PageHeader title="Executive dashboard" subtitle="Live operational and financial overview" />
      <div className="stat-grid">{cards.map(([label, value, Icon, tone]) =>
        <div className="stat-card" key={label}>
          <div><span>{label}</span><strong>{loading ? "…" : value}</strong><small><TrendingUp size={13}/> Healthy portfolio</small></div>
          <div className={`stat-icon stat-icon-${tone}`}><Icon size={22} /></div>
        </div>)}</div>
      <div className="dashboard-grid">
        <div className="panel revenue-panel">
          <div className="panel-heading"><div><span className="eyebrow">FINANCIAL POSITION</span><h2>Revenue performance</h2></div><button className="icon-button" aria-label="Open report"><ArrowUpRight size={18}/></button></div>
          <div className="revenue-total">₹{Number(stats?.revenue ?? 0).toLocaleString("en-IN")}</div>
          <p>Collected against ₹{Number(stats?.outstanding ?? 0).toLocaleString("en-IN")} outstanding</p>
          <div className="revenue-bars" aria-label="Monthly revenue trend">{[42,55,48,68,62,78,71,88,84,92,86,100].map((height,index)=><span key={index} style={{height:`${height}%`}} />)}</div>
        </div>
        <div className="panel">
          <div className="panel-heading"><div><span className="eyebrow">CASH FLOW</span><h2>Billing health</h2></div><CreditCard size={20}/></div>
          <div className="health-ring" style={{"--value":"78%"}}><div><strong>78%</strong><span>On track</span></div></div>
          <div className="metric-row"><span><AlertCircle size={15}/> Outstanding balance</span><strong>₹{Number(stats?.outstanding ?? 0).toLocaleString("en-IN")}</strong></div>
        </div>
      </div>
      <div className="panel mt-5 overflow-hidden">
        <div className="panel-heading px-5 pt-5"><div><span className="eyebrow">LATEST ACTIVITY</span><h2>Recent payments</h2></div></div>
        <div className="overflow-x-auto"><table className="w-full"><thead><tr><th className="table-heading">Reference</th><th className="table-heading">Customer</th><th className="table-heading">Method</th><th className="table-heading">Status</th><th className="table-heading text-right">Amount</th></tr></thead>
          <tbody className="divide-y divide-slate-100">{(stats?.recentPayments || []).map(payment => <tr key={payment.reference} className="hover:bg-slate-50"><td className="table-cell font-semibold">{payment.reference}</td><td className="table-cell">{payment.customer}</td><td className="table-cell capitalize">{payment.method?.replace("_"," ")}</td><td className="table-cell"><span className="status-pill status-paid">{payment.status}</span></td><td className="table-cell text-right font-semibold">₹{Number(payment.amount).toLocaleString("en-IN")}</td></tr>)}</tbody>
        </table></div>
      </div>
    </section>
  );
}
