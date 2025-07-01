import React from "react";

export default function SubmissionTable({ data, onEdit, onDelete }) {
  if (data.length === 0) return <p className="text-gray-500">No submissions found.</p>;

  return (
    <table className="w-full border-collapse bg-white shadow rounded overflow-hidden">
      <thead className="bg-gray-100 text-left">
        <tr>
          <th className="p-3">Name</th>
          <th className="p-3">Email</th>
          <th className="p-3">Phone</th>
          <th className="p-3">Age</th>
          <th className="p-3">Preferred</th>
          <th className="p-3">Actions</th>
        </tr>
      </thead>
      <tbody>
        {data.map((sub) => (
          <tr key={sub.id} className="border-t hover:bg-gray-50">
            <td className="p-3">{sub.full_name}</td>
            <td className="p-3">{sub.email}</td>
            <td className="p-3">{sub.phone_number}</td>
            <td className="p-3">{sub.age}</td>
            <td className="p-3">{sub.preferred_contact}</td>
            <td className="p-3 space-x-2">
              <button onClick={() => onEdit(sub.id)} className="text-blue-600 hover:underline">
                Edit
              </button>
              <button onClick={() => onDelete(sub.id)} className="text-red-600 hover:underline">
                Delete
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
