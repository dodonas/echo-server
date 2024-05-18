# Import necessary modules from flask
from flask import Flask, request, jsonify, send_from_directory
# Import os for environment variable access
import os
# Import requests for making HTTP requests
import requests as req

# Initialize Flask application
app = Flask(__name__)


# Define route for echo service, accepting POST requests
@app.route('/echo', methods=['POST'])
def echo():
    # Get IP address from ipify API
    response = req.get('https://api.ipify.org?format=json')
    ip_address = response.json()['ip']
    # Get data from request
    data = request.json
    # Get message from data, default to empty string if not present
    message = data.get('message', '')
    # Get geolocation data for the IP address
    geolocation = get_geolocation(ip_address)
    # Get environment variable
    environment = os.getenv('ENVIRONMENT')
    # Return JSON response with message, IP, geolocation, and environment
    return jsonify({
        'message': message,
        'ip': ip_address,
        'geolocation': geolocation,
        'environment': environment
    })


# Define route for serving index.html
@app.route('/index.html')
def index():
    # Send index.html from current directory
    return send_from_directory('.', 'index.html')


# Function to get geolocation data for an IP address
def get_geolocation(ip):
    # Get geolocation data from ipinfo API
    response = req.get(f'https://ipinfo.io/{ip}/json')
    data = response.json()
    # Return geolocation data as dictionary
    return {
        'city': data.get('city'),
        'country': data.get('country'),
        'location': {
            'latitude': data.get('loc').split(',')[0],
            'longitude': data.get('loc').split(',')[1]
        }
    }


# Main execution
if __name__ == '__main__':
    # Run Flask application on host 0.0.0.0 and port 5000
    app.run(host='0.0.0.0', port=5000)
