import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import FormPage from "./pages/FormPage";
import SubmissionsPage from "./pages/SubmissionsPage";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
function App() {
  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <h1>🚀 Form Submission Portals Deployed via GitHub Actions</h1>

      <BrowserRouter>
        <Routes>
          <Route path="/" element={<FormPage />} />
          <Route path="/submissions" element={<SubmissionsPage />} />
        </Routes>
        <ToastContainer position="top-right" autoClose={3000} />
      </BrowserRouter>
    </div>
  );
}

export default App;
