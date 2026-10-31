import { useState } from "react";
import { Bell, Boxes, CreditCard, DollarSign, LayoutDashboard, Menu, Package, RefreshCcw, Receipt, Search, Settings, ShoppingCart, Tags, Users, X } from "lucide-react";
import { NavLink, Outlet, useLocation } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";

const navigation = [
  { title: "WORKSPACE", items: [["Dashboard", "/", LayoutDashboard]] },
  { title: "SALES", items: [["Customers", "/customers", Users], ["Quotations", "/quotations", ShoppingCart], ["Subscriptions", "/subscriptions", RefreshCcw]] },
  { title: "CATALOG", items: [["Products", "/products", Package], ["Categories", "/categories", Boxes], ["Variants", "/variants", Tags], ["Subscription plans", "/plans", CreditCard]] },
  { title: "BILLING", items: [["Billing runs", "/billing-runs", Receipt], ["Invoices", "/invoices", Receipt]] },
  { title: "FINANCE", items: [["Payments", "/payments", DollarSign], ["Refunds", "/refunds", RefreshCcw], ["Taxes", "/taxes", DollarSign], ["Discounts", "/discounts", Tags]] },
  { title: "ANALYTICS & ADMIN", items: [["Revenue reports", "/reports/revenue", LayoutDashboard], ["Users", "/users", Users], ["Roles & permissions", "/roles", Users], ["Notifications", "/notifications", Bell], ["Settings", "/settings", Settings]] }
];

export default function MainLayout() {
  const { user } = useAuth();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const location = useLocation();
  const section = navigation.flatMap(group => group.items).find(([, path]) => path === location.pathname)?.[0] || "Dashboard";
  const visibleNavigation = user?.role === "CUSTOMER"
    ? [{ title: "CUSTOMER PORTAL", items: [["Dashboard", "/", LayoutDashboard], ["Subscriptions", "/subscriptions", RefreshCcw], ["Invoices", "/invoices", Receipt], ["Payments", "/payments", DollarSign]] }]
    : navigation;
  return (
    <div className="min-h-screen bg-slate-100">
      <aside className={`fixed inset-y-0 left-0 z-40 bg-slate-950 text-slate-300 transition-all duration-200 lg:translate-x-0 ${mobileOpen ? "translate-x-0" : "-translate-x-full"} ${collapsed ? "w-[76px]" : "w-[260px]"}`}>
        <div className="flex h-16 items-center gap-3 border-b border-slate-800 px-5">
          <div className="grid h-9 w-9 shrink-0 place-items-center rounded-lg bg-brand-500 font-bold text-white">B</div>
          {!collapsed && <div><strong className="block text-white">Brightloop</strong><span className="text-xs text-slate-500">Subscription ERP</span></div>}
          <button className="ml-auto text-slate-400 lg:hidden" onClick={() => setMobileOpen(false)}><X size={18} /></button>
        </div>
        <nav className="h-[calc(100vh-64px)] overflow-y-auto px-3 py-4">
          {visibleNavigation.map(group => <div className="mb-4" key={group.title}>{!collapsed && <span className="mb-2 block px-3 text-[10px] font-bold tracking-[.18em] text-slate-600">{group.title}</span>}
            {group.items.map(([label, path, Icon]) => <NavLink to={path} end={path === "/"} key={path} onClick={() => setMobileOpen(false)}
              className={({isActive}) => `mb-1 flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition ${isActive ? "bg-brand-600 text-white" : "hover:bg-slate-900 hover:text-white"}`} title={collapsed ? label : undefined}>
              <Icon size={18} className="shrink-0" />{!collapsed && label}
            </NavLink>)}
          </div>)}
        </nav>
      </aside>
      <div className={`transition-all ${collapsed ? "lg:pl-[76px]" : "lg:pl-[260px]"}`}>
        <header className="sticky top-0 z-30 flex h-16 items-center border-b border-slate-200 bg-white px-4 lg:px-6">
          <button
            className="icon-button mr-1"
            onClick={() => {
              if (window.matchMedia("(max-width: 1023px)").matches) setMobileOpen(value => !value);
              else setCollapsed(value => !value);
            }}
            aria-label="Toggle navigation"
          >
            <Menu size={20} />
          </button>
          <div className="breadcrumbs">Brightloop ERP <span>/</span> <strong>{section}</strong></div>
          <div className="ml-auto flex items-center gap-2">
            <button className="hidden rounded-lg p-2 text-slate-500 hover:bg-slate-100 sm:block" aria-label="Search"><Search size={19} /></button>
            <button className="rounded-lg p-2 text-slate-500 hover:bg-slate-100" aria-label="Notifications"><Bell size={19} /></button>
            <div className="ml-1 flex cursor-default items-center gap-2 rounded-lg border border-slate-200 p-1.5 pr-3" aria-label="Current profile">
              <span className="grid h-8 w-8 place-items-center rounded-md bg-brand-50 font-bold text-brand-700">{user.name?.charAt(0)}</span>
              <span className="hidden text-left md:block"><strong className="block text-xs">{user.name}</strong><small className="text-[10px] text-slate-500">{user.role}</small></span>
            </div>
          </div>
        </header>
        <main className="mx-auto max-w-[1600px] p-4 lg:p-6"><Outlet /></main>
      </div>
    </div>
  );
}
