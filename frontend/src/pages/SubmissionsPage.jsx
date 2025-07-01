import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { toast } from "react-toastify";
import API_CONFIG from "../config.js";

const API_BASE = API_CONFIG.getApiUrl();

export default function SubmissionsPage() {
  const [submissions, setSubmissions] = useState([]);

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
                <h3 className="text-lg font-semibold">{item.full_name}</h3>
                <p>Email: {item.email}</p>
                <p>Phone: {item.phone_number}</p>
                <p>Age: {item.age}</p>
                <p>Preferred Contact: {item.preferred_contact}</p>
                <p className="text-sm text-gray-500">
                  Submitted: {new Date(item.created_at).toLocaleString()}
                </p>
              </div>
              <div className="mt-4 sm:mt-0 flex flex-col space-y-2">
                <Link
                  to="/form"
                  state={{ editId: item.id }}
                  className="text-blue-600 underline"
                >
                  Edit
                </Link>
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
