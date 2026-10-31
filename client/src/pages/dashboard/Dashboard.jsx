import { useEffect, useState } from "react";
import { DollarSign, Receipt, RefreshCcw, Users } from "lucide-react";
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
    ["Customers", stats?.customers ?? 0, Users],
    ["Subscriptions", stats?.subscriptions ?? 0, RefreshCcw],
    ["Invoices", stats?.invoices ?? 0, Receipt],
    ["Revenue", `₹${Number(stats?.revenue ?? 0).toLocaleString("en-IN")}`, DollarSign]
  ];

  return (
    <section>
      <PageHeader title="Executive dashboard" subtitle="Live operational and financial overview" />
      <div className="stat-grid">{cards.map(([label, value, Icon]) =>
        <div className="stat-card" key={label}><div><span>{label}</span><strong>{loading ? "…" : value}</strong></div><div className="stat-icon"><Icon size={22} /></div></div>)}</div>
      <div className="dashboard-grid">
        <div className="panel"><h2>Collected revenue</h2><p>Revenue from completed payments</p><div className="revenue-total">₹{Number(stats?.revenue ?? 0).toLocaleString("en-IN")}</div></div>
        <div className="panel"><h2>Subscription portfolio</h2><p>{stats?.subscriptions ?? 0} subscription records</p><div className="health-bar"><span style={{ width: `${Math.min(100, (stats?.subscriptions ?? 0) * 10)}%` }} /></div></div>
      </div>
    </section>
  );
}
