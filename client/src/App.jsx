import { useEffect, useState } from "react";
import { BrowserRouter, Navigate, NavLink, Route, Routes, useLocation } from "react-router-dom";
import {
  Bell, Boxes, ChevronLeft, CreditCard, DollarSign, LayoutDashboard, Menu, Package,
  RefreshCcw, Receipt, Search, Settings, ShoppingCart, Tags, Users, X
} from "lucide-react";
import axios from "axios";
import "./App.css";

const api = axios.create({ baseURL: import.meta.env.VITE_API_URL || "http://localhost:5000/api" });
api.interceptors.request.use(config => {
  const token = localStorage.getItem("brightloop_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

const navGroups = [
  { title: "Workspace", items: [["Dashboard", "/", LayoutDashboard]] },
  { title: "Sales", items: [["Customers","/customers",Users],["Quotations","/quotations",ShoppingCart],["Subscriptions","/subscriptions",RefreshCcw]] },
  { title: "Catalog", items: [["Products","/products",Package],["Categories","/categories",Boxes],["Variants","/variants",Tags],["Subscription plans","/plans",CreditCard]] },
  { title: "Billing & Finance", items: [["Billing runs","/billing-runs",Receipt],["Invoices","/invoices",Receipt],["Payments","/payments",DollarSign],["Refunds","/refunds",RefreshCcw],["Taxes","/taxes",DollarSign],["Discounts","/discounts",Tags]] },
  { title: "Analytics & Admin", items: [["Revenue reports","/reports/revenue",LayoutDashboard],["Users","/users",Users],["Roles","/roles",Users],["Notifications","/notifications",Bell],["Settings","/settings",Settings]] }
];

function Login({ onLogin }) {
  const [form,setForm] = useState({email:"admin@brightloop.local",password:"Admin123!"});
  const [error,setError] = useState("");
  const submit = async event => {
    event.preventDefault(); setError("");
    try { const {data}=await api.post("/auth/login",form); localStorage.setItem("brightloop_token",data.token); localStorage.setItem("brightloop_user",JSON.stringify(data.user)); onLogin(data.user); }
    catch(e){ setError(e.response?.data?.message || "Unable to sign in"); }
  };
  return <div className="login-page"><form className="login-card" onSubmit={submit}>
    <div className="brand-mark">B</div><h1>Welcome to Brightloop</h1><p>Sign in to manage your subscription business</p>
    {error && <div className="alert">{error}</div>}
    <label>Email address<input type="email" value={form.email} onChange={e=>setForm({...form,email:e.target.value})} required /></label>
    <label>Password<input type="password" value={form.password} onChange={e=>setForm({...form,password:e.target.value})} required /></label>
    <button className="primary" type="submit">Sign in</button>
    <div className="login-hint">Seed account: admin@brightloop.local / Admin123!</div>
  </form></div>;
}

const resourcePaths = {
  "/customers":"Customer", "/quotations":"Quotation", "/subscriptions":"Subscription", "/products":"Product", "/categories":"Category",
  "/variants":"Product Variant", "/plans":"Subscription Plan", "/billing-runs":"Billing Run", "/invoices":"Invoice", "/payments":"Payment",
  "/refunds":"Refund", "/taxes":"Tax", "/discounts":"Discount", "/users":"User", "/roles":"Role", "/notifications":"Notification", "/settings":"Setting"
};
const endpointFor = path => path;

function Collection({ path, title }) {
  const [rows,setRows]=useState([]), [search,setSearch]=useState(""), [loading,setLoading]=useState(true), [error,setError]=useState("");
  const load=async()=>{setLoading(true);setError("");try{const {data}=await api.get(endpointFor(path),{params:{search}});setRows(data.data||[]);}catch(e){setError(e.response?.data?.message||"Unable to load records");}finally{setLoading(false)}};
  useEffect(()=>{load()},[path]);
  const fields = rows[0] ? Object.keys(rows[0]).filter(k=>!["password_hash","refresh_token"].includes(k)).slice(0,6) : ["id","name","status"];
  return <section><PageHeader title={title} subtitle={`Manage and maintain ${title.toLowerCase()} records`} action={<button className="primary" onClick={load}><RefreshCcw size={16}/> Refresh</button>} />
    <div className="toolbar"><div className="searchbox"><Search size={17}/><input placeholder={`Search ${title.toLowerCase()}...`} value={search} onChange={e=>setSearch(e.target.value)} onKeyDown={e=>e.key==="Enter"&&load()}/></div><button className="secondary" onClick={load}>Search</button></div>
    {error&&<div className="alert">{error}</div>}
    <div className="table-card"><table><thead><tr>{fields.map(k=><th key={k}>{k.replaceAll("_"," ").toUpperCase()}</th>)}</tr></thead><tbody>
      {loading?<tr><td colSpan={fields.length} className="empty">Loading records...</td></tr>:rows.length?rows.map(row=><tr key={row.id}>{fields.map(k=><td key={k}>{row[k]===null||row[k]===""?"—":String(row[k])}</td>)}</tr>):<tr><td colSpan={fields.length} className="empty">No records found</td></tr>}
    </tbody></table></div>
  </section>;
}

function PageHeader({title,subtitle,action}){return <div className="page-header"><div><div className="eyebrow">BRIGHTLOOP ERP</div><h1>{title}</h1><p>{subtitle}</p></div>{action}</div>}

function Dashboard(){
  const [stats,setStats]=useState(null),[error,setError]=useState("");
  useEffect(()=>{api.get("/dashboard/summary").then(({data})=>setStats(data.data)).catch(e=>setError(e.response?.data?.message||"Unable to load dashboard"))},[]);
  const cards=[["Customers",stats?.customers??0,Users],["Active subscriptions",stats?.subscriptions??0,RefreshCcw],["Invoices",stats?.invoices??0,Receipt],["Revenue",`₹${Number(stats?.revenue||0).toLocaleString("en-IN")}`,DollarSign]];
  return <section><PageHeader title="Executive dashboard" subtitle="Business performance and operational overview" />
    {error&&<div className="alert">{error}</div>}<div className="stat-grid">{cards.map(([label,value,Icon])=><div className="stat-card" key={label}><div><span>{label}</span><strong>{value}</strong></div><div className="stat-icon"><Icon size={22}/></div></div>)}</div>
    <div className="dashboard-grid"><div className="panel"><h2>Revenue overview</h2><p>Collected revenue</p><div className="revenue-total">₹{Number(stats?.revenue||0).toLocaleString("en-IN")}</div></div><div className="panel"><h2>Subscription health</h2><p>{stats?.subscriptions||0} current subscriptions in the system</p><div className="health-bar"><span style={{width:`${Math.min(100,(stats?.subscriptions||0)*10)}%`}} /></div></div></div>
  </section>;
}

function RevenueReport() {
  const [rows,setRows]=useState([]),[error,setError]=useState("");
  useEffect(()=>{api.get("/reports/revenue").then(({data})=>setRows(data.data||[])).catch(e=>setError(e.response?.data?.message||"Unable to load report"))},[]);
  return <section><PageHeader title="Revenue Report" subtitle="Monthly completed payment revenue"/>
    {error&&<div className="alert">{error}</div>}<div className="table-card"><table><thead><tr><th>MONTH</th><th>REVENUE</th></tr></thead><tbody>{rows.length?rows.map((row,i)=><tr key={i}><td>{row.month}</td><td>₹{Number(row.amount||0).toLocaleString("en-IN")}</td></tr>):<tr><td colSpan="2" className="empty">No revenue recorded</td></tr>}</tbody></table></div>
  </section>;
}

function Layout({user,onLogout}) {
  const [collapsed,setCollapsed]=useState(false),[mobile,setMobile]=useState(false);
  const location=useLocation(), title=resourcePaths[location.pathname] || (location.pathname.startsWith("/reports")?"Revenue Report": "Dashboard");
  return <div className={`app-shell ${collapsed?"collapsed":""}`}><aside className={mobile?"mobile-open":""}>
    <div className="brand"><div className="brand-mark">B</div>{!collapsed&&<div><strong>Brightloop</strong><span>Subscription ERP</span></div>}<button className="mobile-close" onClick={()=>setMobile(false)}><X size={18}/></button></div>
    <nav>{navGroups.map(group=><div className="nav-group" key={group.title}>{!collapsed&&<span>{group.title}</span>}{group.items.map(([label,to,Icon])=><NavLink to={to} end={to==="/"} onClick={()=>setMobile(false)} key={to}><Icon size={18}/>{!collapsed&&label}</NavLink>)}</div>)}</nav>
  </aside><div className="main"><header><button className="icon-button desktop-toggle" onClick={()=>setCollapsed(!collapsed)}>{collapsed?<Menu size={20}/>:<ChevronLeft size={20}/>}</button><button className="icon-button mobile-menu" onClick={()=>setMobile(true)}><Menu size={20}/></button>
    <div className="breadcrumbs">Brightloop ERP <span>/</span> <strong>{title}</strong></div><div className="top-actions"><button className="icon-button"><Search size={19}/></button><button className="icon-button"><Bell size={19}/></button><button className="user-menu" onClick={onLogout}><span>{user?.name?.charAt(0)||"A"}</span><div><strong>{user?.name||"Admin"}</strong><small>{user?.role||"SUPER_ADMIN"}</small></div></button></div></header>
    <main><Routes><Route path="/" element={<Dashboard/>}/>{Object.entries(resourcePaths).map(([path,name])=><Route key={path} path={path} element={<Collection path={path} title={name}/>}/>)}
      <Route path="/reports/revenue" element={<RevenueReport/>}/><Route path="*" element={<Navigate to="/" replace/>}/></Routes></main></div></div>;
}

export default function App(){
  const [user,setUser]=useState(()=>{try{return JSON.parse(localStorage.getItem("brightloop_user"))}catch{return null}});
  const logout=()=>{localStorage.removeItem("brightloop_token");localStorage.removeItem("brightloop_user");setUser(null)};
  return <BrowserRouter>{user?<Layout user={user} onLogout={logout}/>:<Routes><Route path="*" element={<Login onLogin={setUser}/>}/></Routes>}</BrowserRouter>;
}
