import React, { useState, useEffect } from "react";
import { useNavigate, useLocation, Link } from "react-router-dom";
import { toast } from "react-toastify";
import API_CONFIG from "../config.js";

const API_BASE = API_CONFIG.getApiUrl();

const emptyForm = {
  full_name: "",
  email: "",
  phone_number: "",
  age: "",
  address: "",
  preferred_contact: "Email"
};

export default function FormPage() {
  const [formData, setFormData] = useState(emptyForm);
  const [errors, setErrors] = useState({});
  const navigate = useNavigate();
  const location = useLocation();
  const editingId = location.state?.editId;

  useEffect(() => {
    if (editingId) {
      fetch(`${API_BASE}/submissions/${editingId}`)
        .then(res => {
          if (!res.ok) throw new Error("Not found");
          return res.json();
        })
        .then(data => {
          if (data && data.id) setFormData(data);
          else throw new Error("Invalid data");
        })
        .catch(() => {
          toast.error("Failed to load submission");
          setFormData(emptyForm); // fallback to empty form
        });
    } else {
      setFormData(emptyForm);
    }
  }, [editingId]);

  const handleChange = e => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setErrors({ ...errors, [e.target.name]: false }); // clear error on type
  };

  const handleSubmit = async e => {
    e.preventDefault();

    // Validate
    const newErrors = {};
    ["full_name", "email", "phone_number", "age", "preferred_contact"].forEach(field => {
      if (!formData[field]?.toString().trim()) newErrors[field] = true;
    });

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error("Please fill in all required fields");
      return;
    }

    const url = editingId
      ? `${API_BASE}/submissions/${editingId}`
      : `${API_BASE}/submissions`;
    const method = editingId ? "PUT" : "POST";

    try {
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(`Server error: ${res.status} - ${errorText}`);
      }

      toast.success(editingId ? "Updated successfully!" : "Submitted successfully!");
      navigate("/submissions");
    } catch (err) {
      console.error("❌ Fetch error:", err);
      toast.error("Submission failed. Please try again.");
    }
  };

  return (
    <div className="max-w-xl mx-auto p-4 sm:p-6 md:p-8 bg-white shadow rounded mt-6">
      <Link
        to="/submissions"
        className="mb-6 inline-block bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
      >
        View Submissions
      </Link>

      <form onSubmit={handleSubmit} className="space-y-5">
        <h2 className="text-2xl font-bold">{editingId ? "Edit Submission" : "New Submission"}</h2>

        {/* Full Name */}
        <div>
          <label className="font-medium">
            Full Name<span className="text-red-500">*</span>
          </label>
          {errors.full_name && <p className="text-red-500 text-sm">Required</p>}
          <input
            name="full_name"
            value={formData.full_name}
            onChange={handleChange}
            className={`w-full border rounded p-2 ${errors.full_name ? "border-red-500" : ""}`}
            placeholder="Full Name"
          />
        </div>

        {/* Email */}
        <div>
          <label className="font-medium">
            Email<span className="text-red-500">*</span>
          </label>
          {errors.email && <p className="text-red-500 text-sm">Required</p>}
          <input
            name="email"
            type="email"
            value={formData.email}
            onChange={handleChange}
            className={`w-full border rounded p-2 ${errors.email ? "border-red-500" : ""}`}
            placeholder="Email"
          />
        </div>

        {/* Phone */}
        <div>
          <label className="font-medium">
            Phone Number<span className="text-red-500">*</span>
          </label>
          {errors.phone_number && <p className="text-red-500 text-sm">Required</p>}
          <input
            name="phone_number"
            value={formData.phone_number}
            onChange={handleChange}
            className={`w-full border rounded p-2 ${errors.phone_number ? "border-red-500" : ""}`}
            placeholder="Phone Number"
          />
        </div>

        {/* Age */}
        <div>
          <label className="font-medium">
            Age<span className="text-red-500">*</span>
          </label>
          {errors.age && <p className="text-red-500 text-sm">Required</p>}
          <input
            name="age"
            type="number"
            min="18"
            max="120"
            value={formData.age}
            onChange={handleChange}
            className={`w-full border rounded p-2 ${errors.age ? "border-red-500" : ""}`}
            placeholder="Age"
          />
        </div>

        {/* Address */}
        <div>
          <label className="font-medium">Address</label>
          <textarea
            name="address"
            value={formData.address}
            onChange={handleChange}
            className="w-full border rounded p-2"
            placeholder="Address (optional)"
          />
        </div>

        {/* Preferred Contact */}
        <div>
          <label className="font-medium">
            Preferred Contact<span className="text-red-500">*</span>
          </label>
          {errors.preferred_contact && <p className="text-red-500 text-sm">Required</p>}
          <select
            name="preferred_contact"
            value={formData.preferred_contact}
            onChange={handleChange}
            className={`w-full border rounded p-2 ${errors.preferred_contact ? "border-red-500" : ""}`}
          >
            <option>Email</option>
            <option>Phone</option>
            <option>Both</option>
          </select>
        </div>

        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 w-full"
        >
          {editingId ? "Update" : "Submit"}
        </button>
      </form>
    </div>
  );
}
