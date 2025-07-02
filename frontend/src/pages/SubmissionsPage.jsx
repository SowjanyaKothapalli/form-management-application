import React, { useEffect, useState } from "react";
import jsPDF from "jspdf";
import "jspdf-autotable";
import { Link } from "react-router-dom";
import { toast } from "react-toastify";
import API_CONFIG from "../config.js";

const API_BASE = API_CONFIG.getApiUrl();

export default function SubmissionsPage() {
  const [submissions, setSubmissions] = useState([]);
  const [editingId, setEditingId] = useState(null);
  const [editData, setEditData] = useState({});

  useEffect(() => {
    fetch(`${API_BASE}/submissions`)
      .then((res) => res.json())
      .then((data) => setSubmissions(data))
      .catch(() => toast.error("Failed to load submissions"));
  }, []);

  const deleteSubmission = (id) => {
    // show a confirmation toast with a custom action
    toast.info(
      ({ closeToast }) => (
        <div>
          <p className="font-medium mb-1">Are you sure you want to delete this?</p>
          <div className="space-x-2">
            <button
              onClick={async () => {
                try {
                  const res = await fetch(`${API_BASE}/submissions/${id}`, {
                    method: "DELETE",
                  });

                  if (res.status === 204) {
                    setSubmissions(submissions.filter((s) => s.id !== id));
                    toast.dismiss(); // Close confirmation toast
                    toast.success("Submission deleted");
                  } else {
                    throw new Error("Failed to delete");
                  }
                } catch (err) {
                  toast.error("Error deleting submission");
                }
              }}
              className="bg-red-600 text-white px-3 py-1 rounded"
            >
              Yes, Delete
            </button>
            <button
              onClick={closeToast}
              className="bg-gray-200 px-3 py-1 rounded"
            >
              Cancel
            </button>
          </div>
        </div>
      ),
      { autoClose: false }
    );
  };

  return (
    <div className="max-w-3xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-4">All Submissions</h2>

      {/* Export Buttons */}
      <div className="mb-4 flex gap-2">
        <button
          className="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
          onClick={() => exportToCSV(submissions)}
          disabled={submissions.length === 0}
        >
          Export CSV
        </button>
        <button
          className="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
          onClick={() => exportToPDF(submissions)}
          disabled={submissions.length === 0}
        >
          Export PDF
        </button>
      </div>

      {submissions.length === 0 ? (
        <p className="text-gray-600">No submissions found.</p>
      ) : (
        <div className="space-y-4">
          {submissions.map((item) => (
            <div
              key={item.id}
              className="p-4 border rounded shadow-sm bg-white flex flex-col sm:flex-row sm:justify-between"
            >
              <div>
                {editingId === item.id ? (
                  <form
                    onSubmit={async (e) => {
                      e.preventDefault();
                      try {
                        const res = await fetch(`${API_BASE}/submissions/${item.id}`, {
                          method: "PUT",
                          headers: { "Content-Type": "application/json" },
                          body: JSON.stringify(editData),
                        });
                        if (!res.ok) throw new Error("Update failed");
                        const updated = await res.json();
                        setSubmissions(submissions.map(s => s.id === item.id ? updated : s));
                        setEditingId(null);
                        setEditData({});
                        toast.success("Submission updated");
                      } catch {
                        toast.error("Failed to update");
                      }
                    }}
                    className="space-y-2"
                  >
                    <input
                      className="border rounded p-1 w-full"
                      value={editData.full_name || ""}
                      onChange={e => setEditData({ ...editData, full_name: e.target.value })}
                      placeholder="Full Name"
                      required
                    />
                    <input
                      className="border rounded p-1 w-full"
                      value={editData.email || ""}
                      onChange={e => setEditData({ ...editData, email: e.target.value })}
                      placeholder="Email"
                      required
                    />
                    <input
                      className="border rounded p-1 w-full"
                      value={editData.phone_number || ""}
                      onChange={e => setEditData({ ...editData, phone_number: e.target.value })}
                      placeholder="Phone Number"
                      required
                    />
                    <input
                      className="border rounded p-1 w-full"
                      type="number"
                      value={editData.age || ""}
                      onChange={e => setEditData({ ...editData, age: e.target.value })}
                      placeholder="Age"
                      required
                    />
                    <input
                      className="border rounded p-1 w-full"
                      value={editData.address || ""}
                      onChange={e => setEditData({ ...editData, address: e.target.value })}
                      placeholder="Address"
                    />
                    <select
                      className="border rounded p-1 w-full"
                      value={editData.preferred_contact || "Email"}
                      onChange={e => setEditData({ ...editData, preferred_contact: e.target.value })}
                      required
                    >
                      <option>Email</option>
                      <option>Phone</option>
                      <option>Both</option>
                    </select>
                    <div className="flex gap-2 mt-2">
                      <button type="submit" className="bg-blue-600 text-white px-3 py-1 rounded">Save</button>
                      <button type="button" className="bg-gray-300 px-3 py-1 rounded" onClick={() => { setEditingId(null); setEditData({}); }}>Cancel</button>
                    </div>
                  </form>
                ) : (
                  <>
                    <h3 className="text-lg font-semibold">{item.full_name}</h3>
                    <p>Email: {item.email}</p>
                    <p>Phone: {item.phone_number}</p>
                    <p>Age: {item.age}</p>
                    <p>Preferred Contact: {item.preferred_contact}</p>
                    <p className="text-sm text-gray-500">
                      Submitted: {new Date(item.created_at).toLocaleString()}
                    </p>
                  </>
                )}
              </div>
              <div className="mt-4 sm:mt-0 flex flex-col space-y-2">
                {editingId === item.id ? null : (
                  <button
                    onClick={() => { setEditingId(item.id); setEditData(item); }}
                    className="text-blue-600 underline"
                  >
                    Edit
                  </button>
                )}
                <button
                  onClick={() => deleteSubmission(item.id)}
                  className="text-red-600 underline"
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// Export to CSV
function exportToCSV(data) {
  if (!data.length) return;
  const headers = Object.keys(data[0]);
  const csvRows = [
    headers.join(","),
    ...data.map(row => headers.map(field => JSON.stringify(row[field] ?? "")).join(","))
  ];
  const csvString = csvRows.join("\n");
  const blob = new Blob([csvString], { type: "text/csv" });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "submissions.csv";
  a.click();
  window.URL.revokeObjectURL(url);
}

// Export to PDF
function exportToPDF(data) {
  if (!data.length) return;
  const doc = new jsPDF();
  const headers = [Object.keys(data[0])];
  const body = data.map(row => Object.values(row));
  doc.autoTable({ head: headers, body });
  doc.save("submissions.pdf");
}
