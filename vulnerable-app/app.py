from flask import Flask, request, render_template_string
import requests

app = Flask(__name__)

@app.route('/')
def home():
    return """
    <h1>Vulnerable Python App</h1>
    <p>This app uses outdated dependencies with known vulnerabilities.</p>
    <ul>
        <li>Flask 2.0.1</li>
        <li>requests 2.25.1</li>
        <li>urllib3 1.26.4</li>
        <li>Jinja2 3.0.0</li>
        <li>cryptography 3.3.2</li>
    </ul>
    """

@app.route('/fetch')
def fetch_url():
    # Vulnerable: No URL validation
    url = request.args.get('url', '')
    if url:
        try:
            response = requests.get(url)
            return f"Fetched: {response.status_code}"
        except:
            return "Error fetching URL"
    return "No URL provided"

@app.route('/template')
def render_template():
    # Vulnerable: Server-Side Template Injection
    name = request.args.get('name', 'World')
    template = f"<h1>Hello {name}!</h1>"
    return render_template_string(template)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
