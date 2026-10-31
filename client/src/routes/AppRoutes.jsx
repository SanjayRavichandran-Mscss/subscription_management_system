import { Navigate, Route, Routes } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import MainLayout from "../components/layout/MainLayout";
import Login from "../pages/auth/Login";
import Register from "../pages/auth/Register";
import Dashboard from "../pages/dashboard/Dashboard";
import ResourcePage from "../pages/common/ResourcePage";
import RevenueReports from "../pages/reports/RevenueReports";
import ResetPassword from "../pages/auth/ResetPassword";
import ForgotPassword from "../pages/auth/ForgotPassword";

const resources = [
  ["customers", "Customers"], ["quotations", "Quotations"], ["subscriptions", "Subscriptions"],
  ["products", "Products"], ["categories", "Categories"], ["variants", "Product Variants"],
  ["plans", "Subscription Plans"], ["billing-runs", "Billing Runs"], ["invoices", "Invoices"],
  ["payments", "Payments"], ["refunds", "Refunds"], ["taxes", "Taxes"], ["discounts", "Discounts"],
  ["users", "Users"], ["roles", "Roles & Permissions"], ["notifications", "Notifications"], ["settings", "Settings"]
];

export default function AppRoutes() {
  const { user } = useAuth();
  return (
    <Routes>
      <Route path="/login" element={!user ? <Login /> : <Navigate to="/" replace />} />
      <Route path="/register" element={!user ? <Register /> : <Navigate to="/" replace />} />
      <Route path="/reset-password" element={!user ? <ResetPassword /> : <Navigate to="/" replace />} />
      <Route path="/forgot-password" element={!user ? <ForgotPassword /> : <Navigate to="/" replace />} />
      <Route element={user ? <MainLayout /> : <Navigate to="/login" replace />}>
        <Route path="/" element={<Dashboard />} />
        {resources.map(([slug, title]) => (
          <Route key={slug} path={`/${slug}`} element={<ResourcePage resource={slug} title={title} />} />
        ))}
        <Route path="/reports/revenue" element={<RevenueReports />} />
      </Route>
      <Route path="*" element={<Navigate to={user ? "/" : "/login"} replace />} />
    </Routes>
  );
}
