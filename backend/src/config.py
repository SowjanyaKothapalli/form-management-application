import os

# Only load .env when NOT testing
if os.getenv("FLASK_ENV") != "testing":
    from dotenv import load_dotenv
    load_dotenv()

class Config:
    # Use DATABASE_URL from environment (Lambda will use this)
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")

    # Fallback if DATABASE_URL isn't set (local development safety)
    if not SQLALCHEMY_DATABASE_URI:
        DB_USER = os.getenv("DB_USER", "postgres")
        DB_PASSWORD = os.getenv("DB_PASSWORD", "")
        DB_HOST = os.getenv("DB_HOST", "localhost")
        DB_PORT = os.getenv("DB_PORT", "5432")
        DB_NAME = os.getenv("DB_NAME", "formdb")
        SQLALCHEMY_DATABASE_URI = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    TESTING = False

class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
