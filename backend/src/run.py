from dotenv import load_dotenv
load_dotenv()
from .config import Config
from .database import db
from .routes import routes


from flask import Flask
from flask_cors import CORS


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    # Allow override from test config
    if app.config.get("TESTING"):
        app.config["SQLALCHEMY_DATABASE_URI"] = app.config.get("SQLALCHEMY_DATABASE_URI")

    
    CORS(app,
         origins=["http://127.0.0.1:5173", "http://localhost:3000", "http://localhost:5173"],
         methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
         allow_headers=["Content-Type"],
         supports_credentials=True
    )

    db.init_app(app)
    app.register_blueprint(routes)

    return app

app = create_app()

if __name__ == "__main__":
    app.run(debug=True)
