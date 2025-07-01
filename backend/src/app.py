from dotenv import load_dotenv
load_dotenv()
import sys
import os
sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from dotenv import load_dotenv
import os

from config import Config
from database import db  # Your SQLAlchemy instance
from routes import api   # Your API routes

# Load environment variables from .env file
load_dotenv()

def create_app():
    app = Flask(__name__)
    
    # Load configuration from config.py
    app.config.from_object(Config)

    # Initialize database and migrations
    db.init_app(app)
    migrate = Migrate(app, db)

    # Enable CORS for frontend communication
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    # Register API blueprint
    app.register_blueprint(api)

    # Optional: Auto-create tables if they don't exist
    with app.app_context():
        from model import Submission  # Make sure to import all models
        db.create_all()

    return app
