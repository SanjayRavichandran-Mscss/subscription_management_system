import { useState } from "react";
import { Link } from "react-router-dom";
import toast from "react-hot-toast";
import api from "../../services/api";

export default function ForgotPassword() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const submit = async event => {
    event.preventDefault();
    setLoading(true);
    try {
      await api.post("/auth/forgot-password", { email });
      toast.success("Password reset instructions have been sent if the account exists");
    } catch (error) {
      toast.error(error.response?.data?.message || "Unable to request password reset");
    } finally { setLoading(false); }
  };
  return <main className="grid min-h-screen place-items-center bg-slate-950 px-4">
    <form className="w-full max-w-md rounded-2xl bg-white p-8" onSubmit={submit}>
      <h1 className="text-2xl font-bold text-slate-900">Forgot password</h1>
      <p className="mb-6 mt-2 text-sm text-slate-500">Enter your account email address.</p>
      <input className="form-input mb-4" type="email" required value={email} onChange={event => setEmail(event.target.value)} placeholder="Email address"/>
      <button className="btn-primary w-full" disabled={loading}>{loading ? "Sending..." : "Send reset link"}</button>
      <Link className="mt-5 block text-center text-sm font-semibold text-brand-600" to="/login">Back to sign in</Link>
    </form>
  </main>;
}
