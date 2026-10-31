import { useEffect, useState } from "react";
import toast from "react-hot-toast";
import api from "../../services/api";
import PageHeader from "../../components/layout/PageHeader";
import DataTable from "../../components/common/DataTable";

export default function RevenueReports() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    api.get("/reports/revenue").then(({ data }) => setRows(data.data || []))
      .catch(error => toast.error(error.response?.data?.message || "Unable to load revenue report"))
      .finally(() => setLoading(false));
  }, []);
  return <section><PageHeader title="Revenue reports" subtitle="Monthly revenue from completed payments" />
    {loading ? <div className="table-card"><div className="empty">Loading report...</div></div> :
      <DataTable rows={rows.map(row => ({ month: row.month, revenue: `₹${Number(row.amount || 0).toLocaleString("en-IN")}` }))} />}
  </section>;
}
