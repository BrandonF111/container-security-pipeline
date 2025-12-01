# app.py
from flask import Flask, request, render_template_string
import requests

app = Flask(__name__)

@app.route('/')
def home():
    return "Vulnerable Python App - Security Scanning Demo"

@app.route('/fetch')
def fetch_url():
    # Uses requests (2.20.0 has known vulnerabilities)
    url = request.args.get('url', 'http://example.com')
    try:
        response = requests.get(url, timeout=5)
        return f"Fetched: {response.status_code}"
    except:
        return "Error fetching URL"

@app.route('/render')
def render():
    # Uses Jinja2 (2.10.0 has SSTI vulnerabilities)
    template = request.args.get('template', '<h1>Hello World</h1>')
    return render_template_string(template)

@app.route('/hello/<name>')
def hello(name):
    # Flask route using all components
    return f"Hello, {name}!"

if __name__ == '__main__':
    # Flask 1.1.1 has various security issues
    app.run(host='0.0.0.0', port=5000, debug=True)
