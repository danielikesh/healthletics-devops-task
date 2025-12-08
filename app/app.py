from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

@app.route("/")
def home():
    return "DevOps Intern Task Working!", 200

if __name__ == "__main__":
    # Port 8080 because we'll expose this in Docker/K8s
    app.run(host="0.0.0.0", port=8080)
