import { useEffect, useState } from "react";
import { Plus, RefreshCcw, Search, X } from "lucide-react";
import toast from "react-hot-toast";
import api from "../../services/api";
import PageHeader from "../../components/layout/PageHeader";
import DataTable from "../../components/common/DataTable";

export default function ResourcePage({ resource, title }) {
  const [rows, setRows] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({});

  const load = async (term = search) => {
    setLoading(true);
    try {
      const { data } = await api.get(`/${resource}`, { params: { search: term } });
      setRows(data.data || []);
    } catch (error) {
      toast.error(error.response?.data?.message || `Unable to load ${title.toLowerCase()}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(""); }, [resource]);

  const fields = rows.length
    ? Object.keys(rows[0]).filter(key => !["id","created_at","updated_at","password_hash","refresh_token"].includes(key)).slice(0, 12)
    : ["name"];

  const save = async event => {
    event.preventEvent?.();
    event.preventDefault();
    try {
      if (editing?.id) await api.put(`/${resource}/${editing.id}`, form);
      else await api.post(`/${resource}`, form);
      toast.success(editing?.id ? "Record updated" : "Record created");
      setEditing(null);
      setForm({});
      load();
    } catch (error) { toast.error(error.response?.data?.message || "Unable to save record"); }
  };

  const remove = async row => {
    if (!window.confirm(`Delete this ${title.toLowerCase()} record?`)) return;
    try {
      await api.delete(`/${resource}/${row.id}`);
      toast.success("Record deleted");
      load();
    } catch (error) { toast.error(error.response?.data?.message || "Unable to delete record"); }
  };

  const openCreate = () => { setEditing({}); setForm({}); };
  const openEdit = row => { setEditing(row); setForm(Object.fromEntries(Object.entries(row).filter(([key]) => fields.includes(key)))); };

  return (
    <section>
      <PageHeader title={title} subtitle={`Search, review, and maintain ${title.toLowerCase()}`}
        actions={<><button className="btn-secondary" onClick={() => load()}><RefreshCcw size={16} /> Refresh</button><button className="btn-primary" onClick={openCreate}><Plus size={16}/> Add record</button></>} />
      <div className="panel mb-4 flex flex-wrap gap-3 p-3">
        <div className="relative min-w-[240px] flex-1"><Search className="absolute left-3 top-3 text-slate-400" size={17}/><input className="form-input pl-10" value={search} onChange={event => setSearch(event.target.value)} onKeyDown={event => event.key === "Enter" && load(search)} placeholder={`Search ${title.toLowerCase()}...`} /></div>
        <button className="btn-secondary" onClick={() => load(search)}>Search</button>
      </div>
      {loading ? <div className="panel p-12 text-center text-sm text-slate-500">Loading records...</div> : <DataTable rows={rows} onEdit={openEdit} onDelete={remove}/>}
      {editing && <div className="fixed inset-0 z-50 grid place-items-center bg-slate-950/40 p-4" onMouseDown={event => event.target === event.currentTarget && setEditing(null)}>
        <form onSubmit={save} className="panel max-h-[90vh] w-full max-w-2xl overflow-y-auto">
          <div className="flex items-center justify-between border-b border-slate-200 px-5 py-4"><div><h2 className="font-semibold text-slate-900">{editing.id ? "Edit" : "Create"} {title}</h2><p className="mt-1 text-xs text-slate-500">Complete the record details below.</p></div><button type="button" className="rounded-md p-2 hover:bg-slate-100" onClick={() => setEditing(null)}><X size={18}/></button></div>
          <div className="grid gap-4 p-5 sm:grid-cols-2">{fields.map(field => <label key={field} className="block text-sm font-medium text-slate-700">{field.replaceAll("_"," ").replace(/\b\w/g, char => char.toUpperCase())}<input className="form-input mt-1.5" value={form[field] ?? ""} required={["name","number","email"].includes(field)} onChange={event => setForm({...form,[field]: event.target.value})}/></label>)}</div>
          <div className="flex justify-end gap-3 border-t border-slate-200 px-5 py-4"><button type="button" className="btn-secondary" onClick={() => setEditing(null)}>Cancel</button><button className="btn-primary" type="submit">Save record</button></div>
        </form>
      </div>}
    </section>
  );
}
