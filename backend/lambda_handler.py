# This file adapts your Flask application to work with AWS Lambda
# Place this file in your backend directory and include it in the Lambda package

import sys
import os

# Add the src directory to the path so we can import from it
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'src'))

from src.app import create_app
import json
import awsgi

# Initialize the Flask application outside the handler to improve performance
app = create_app()

def handler(event, context):
    """
    AWS Lambda handler function that adapts API Gateway events to Flask
    """
    # Print the event for debugging (CloudWatch logs)
    print('Event:', json.dumps(event))
    
    # Convert API Gateway v2 format to v1 format for awsgi
    if 'version' in event and event['version'] == '2.0' and 'httpMethod' not in event:
        # API Gateway v2 format conversion to v1 format
        if 'requestContext' in event and 'http' in event['requestContext']:
            # Extract the HTTP method from requestContext.http.method
            method = event['requestContext']['http']['method']
            
            # Create a new event dictionary with httpMethod key
            v1_event = {
                'httpMethod': method,
                'path': event.get('rawPath', '/'),
                'queryStringParameters': event.get('queryStringParameters', {}),
                'headers': event.get('headers', {}),
                'body': event.get('body', ''),
                'isBase64Encoded': event.get('isBase64Encoded', False),
                'pathParameters': event.get('pathParameters', {})
            }
            
            # Update the event to use for awsgi
            event = v1_event
    
    # Modify the path if needed to match your API structure
    path = event.get('path', event.get('rawPath', '/'))
    if path == '/':
        if 'path' in event:
            event['path'] = '/api'
        else:
            event['rawPath'] = '/api'
    elif not path.startswith('/api'):
        if 'path' in event:
            event['path'] = f'/api{path}'
        else:
            event['rawPath'] = f'/api{path}'
    
    # Use awsgi to process the API Gateway event with Flask
    return awsgi.response(app, event, context)
