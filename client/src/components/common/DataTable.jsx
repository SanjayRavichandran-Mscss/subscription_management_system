import { Pencil, Trash2 } from "lucide-react";

export default function DataTable({ rows = [], onEdit, onDelete }) {
  const columns = rows.length ? Object.keys(rows[0]).filter(key => !["password_hash","refresh_token"].includes(key)).slice(0, 8) : [];
  const format = value => value === null || value === undefined ? "-" : typeof value === "object" ? JSON.stringify(value) : String(value);
  if (!rows.length) return <div className="panel p-12 text-center text-sm text-slate-500">No records found.</div>;
  return <div className="panel overflow-hidden">
    <div className="overflow-x-auto">
      <table className="w-full min-w-[700px]">
        <thead className="border-b border-slate-200 bg-slate-50"><tr>{columns.map(column => <th key={column} className="table-heading">{column.replaceAll("_"," ")}</th>)}<th className="table-heading text-right">Actions</th></tr></thead>
        <tbody className="divide-y divide-slate-100">{rows.map(row => <tr key={row.id} className="hover:bg-slate-50/70">{columns.map(column => <td key={column} className="table-cell max-w-[220px] truncate" title={format(row[column])}>{format(row[column])}</td>)}
          <td className="table-cell"><div className="flex justify-end gap-1"><button className="rounded-md p-2 text-slate-500 hover:bg-brand-50 hover:text-brand-700" onClick={() => onEdit?.(row)} aria-label="Edit"><Pencil size={16}/></button><button className="rounded-md p-2 text-slate-500 hover:bg-red-50 hover:text-red-600" onClick={() => onDelete?.(row)} aria-label="Delete"><Trash2 size={16}/></button></div></td>
        </tr>)}</tbody>
      </table>
    </div>
  </div>;
}
