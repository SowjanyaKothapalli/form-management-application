import sys
import os

# Add the src directory to the Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
src_dir = os.path.join(current_dir, "src")
sys.path.append(current_dir)
sys.path.append(src_dir)

# Import the Flask app
from src.run import app

# Create the serverless handler
def handler(event, context):
    return serverless_wsgi.handle_request(app, event, context)

# Import serverless_wsgi after the app to avoid circular imports
import serverless_wsgi
