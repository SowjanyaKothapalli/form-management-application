from flask import Blueprint, request, jsonify
#from validators import validate_submission  # Optional: your validation logic
from .model import Submission
from .database import db

# Create a Blueprint named 'api' for consistency with imports
routes = Blueprint("api", __name__)

@routes.route("/", methods=["GET"])
def root():
    return "✅ Flask backend is running. Go to /api/health or use the frontend."


@routes.route("/api/health", methods=["GET"])
def health_check():
    return jsonify({"status": "server is running"}), 200
    #return {"status": "ok"}, 200


@routes.route("/api/submissions", methods=["GET"])
def get_submissions():
    submissions = Submission.query.order_by(Submission.created_at.desc()).all()
    print(f"📦 Found {len(submissions)} submissions")
    return jsonify([s.to_dict() for s in submissions]), 200



@routes.route("/api/submissions/<int:id>", methods=["GET"])
def get_submission(id):
    s = Submission.query.get_or_404(id)
    return jsonify(s.to_dict()), 200

@routes.route("/api/submissions", methods=["POST"])
def create_submission():
    data = request.get_json()
    required_fields = ["full_name", "email", "phone_number", "age", "preferred_contact"]
    for field in required_fields:
        if not data.get(field):
            return jsonify({"error": f"{field} is missing"}), 400

    try:
        age = int(data["age"])
        if age < 18 or age > 120:
            return jsonify({"error": "Invalid age"}), 400
    except ValueError:
        return jsonify({"error": "Age must be a number"}), 400

    if "@" not in data["email"]:
        return jsonify({"error": "Invalid email"}), 400


    s = Submission(**data)
    db.session.add(s)
    db.session.commit()
    return jsonify(s.to_dict()), 201

@routes.route("/api/submissions/<int:id>", methods=["PUT"])
def update_submission(id):
    s = Submission.query.get_or_404(id)
    for key, value in request.get_json().items():
        setattr(s, key, value)
    db.session.commit()
    return jsonify(s.to_dict()), 200

@routes.route("/api/submissions/<int:id>", methods=["DELETE"])
def delete_submission(id):
    s = Submission.query.get_or_404(id)
    db.session.delete(s)
    db.session.commit()
    return '', 204
