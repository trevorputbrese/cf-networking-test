from flask import Flask, render_template_string
import requests
import os

app = Flask(__name__)

# Environment variable for backend URL
BACKEND_URL = os.getenv('BACKEND_URL', 'http://back-end-container:5000')

@app.route('/')
def index():
    try:
        # Attempt connection to backend container
        response = requests.get(f"{BACKEND_URL}/health", timeout=2)
        if response.status_code == 200:
            status = '✅ Successfully connected to back-end-container.'
        else:
            status = f'⚠️ Connection made, but received unexpected status code: {response.status_code}'
    except requests.exceptions.RequestException as e:
        status = f'❌ Failed to connect: {str(e)}'

    # Simple HTML template
    html_template = """
    <html>
      <head><title>Back-End Container Status</title></head>
      <body>
        <h2>Back-End Container Connectivity Check</h2>
        <p>{{ status }}</p>
      </body>
    </html>
    """
    return render_template_string(html_template, status=status)

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
