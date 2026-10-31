import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import toast from "react-hot-toast";
import { useAuth } from "../../context/AuthContext";

export default function Register() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [loading, setLoading] = useState(false);
  const submit = async event => {
    event.preventDefault();
    setLoading(true);
    try { await register(form); toast.success("Account created. Please sign in."); navigate("/login"); }
    catch (error) { toast.error(error.response?.data?.message || "Unable to create account"); }
    finally { setLoading(false); }
  };
  return (
    <main className="grid min-h-screen place-items-center bg-slate-950 px-4 py-12">
      <form className="w-full max-w-md rounded-2xl bg-white p-8 shadow-2xl" onSubmit={submit}>
        <div className="mb-7"><div className="mb-5 grid h-11 w-11 place-items-center rounded-xl bg-brand-600 text-lg font-bold text-white">B</div><h1 className="text-2xl font-bold text-slate-900">Create your account</h1><p className="mt-2 text-sm text-slate-500">Register for the Brightloop customer portal</p></div>
        <label className="mb-4 block text-sm font-medium text-slate-700">Full name<input className="form-input mt-1.5" required value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} /></label>
        <label className="mb-4 block text-sm font-medium text-slate-700">Email address<input className="form-input mt-1.5" type="email" required value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} /></label>
        <label className="mb-2 block text-sm font-medium text-slate-700">Password<input className="form-input mt-1.5" type="password" required minLength={9} value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} /></label>
        <p className="mb-5 text-xs text-slate-500">Use 9+ characters with uppercase, lowercase, and a special character.</p>
        <button className="btn-primary w-full" disabled={loading}>{loading ? "Creating account..." : "Create account"}</button>
        <p className="mt-5 text-center text-sm text-slate-500">Already registered? <Link className="font-semibold text-brand-600" to="/login">Sign in</Link></p>
      </form>
    </main>
  );
}
