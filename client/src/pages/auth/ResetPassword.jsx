import { useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import toast from "react-hot-toast";
import api from "../../services/api";

export default function ResetPassword() {
  const [params] = useSearchParams();
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const submit = async event => {
    event.preventDefault();
    setLoading(true);
    try {
      await api.post("/auth/reset-password", { token: params.get("token"), password });
      toast.success("Password reset successfully");
    } catch (error) {
      toast.error(error.response?.data?.message || "Unable to reset password");
    } finally { setLoading(false); }
  };
  return <main className="grid min-h-screen place-items-center bg-slate-950 px-4">
    <form className="w-full max-w-md rounded-2xl bg-white p-8" onSubmit={submit}>
      <h1 className="text-2xl font-bold text-slate-900">Reset password</h1>
      <p className="mb-6 mt-2 text-sm text-slate-500">Choose a strong new password.</p>
      <input className="form-input mb-4" type="password" required minLength={9} value={password} onChange={event => setPassword(event.target.value)} placeholder="New password"/>
      <button className="btn-primary w-full" disabled={loading}>{loading ? "Resetting..." : "Reset password"}</button>
      <Link className="mt-5 block text-center text-sm font-semibold text-brand-600" to="/login">Back to sign in</Link>
    </form>
  </main>;
}
