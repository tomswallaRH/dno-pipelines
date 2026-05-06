from flask import Flask, jsonify

app = Flask(__name__)


@app.get('/health')
def health() -> tuple:
    return jsonify({
        'status': 'ok',
        'service': 'brewspace-api',
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
