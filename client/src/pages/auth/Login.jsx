import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import toast from "react-hot-toast";
import { useAuth } from "../../context/AuthContext";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: "", password: "" });
  const [loading, setLoading] = useState(false);
  const submit = async event => {
    event.preventDefault();
    setLoading(true);
    try { await login(form); toast.success("Signed in successfully"); navigate("/", { replace: true }); }
    catch (error) { toast.error(error.response?.data?.message || "Unable to sign in"); }
    finally { setLoading(false); }
  };
  return (
    <main className="grid min-h-screen place-items-center bg-slate-950 px-4 py-12">
      <form className="w-full max-w-md rounded-2xl bg-white p-8 shadow-2xl" onSubmit={submit}>
        <div className="mb-7"><div className="mb-5 grid h-11 w-11 place-items-center rounded-xl bg-brand-600 text-lg font-bold text-white">B</div><h1 className="text-2xl font-bold text-slate-900">Welcome to Brightloop</h1><p className="mt-2 text-sm text-slate-500">Sign in to your subscription workspace</p></div>
        <label className="mb-4 block text-sm font-medium text-slate-700">Email address<input className="form-input mt-1.5" type="email" autoComplete="email" required value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} /></label>
        <label className="mb-5 block text-sm font-medium text-slate-700">Password<input className="form-input mt-1.5" type="password" autoComplete="current-password" required value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} /></label>
        <Link className="mb-4 block text-right text-sm font-semibold text-brand-600" to="/forgot-password">Forgot password?</Link>
        <button className="btn-primary w-full" disabled={loading}>{loading ? "Signing in..." : "Sign in"}</button>
        <p className="mt-5 text-center text-sm text-slate-500">New customer? <Link className="font-semibold text-brand-600" to="/register">Create an account</Link></p>
      </form>
    </main>
  );
}
