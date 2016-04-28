import json
from flask import Flask, request
from flask.ext.sqlalchemy import SQLAlchemy
from application.service_clients.esec import make_esec_client
import os
import logging
from logger import logging_config

logging_config.setup_logging()
LOGGER = logging.getLogger(__name__)

LOGGER.info("Starting the server")


app = Flask(__name__, static_folder='static')
db = SQLAlchemy(app)
esec_client = make_esec_client()

# Register routes after establishing the db prevents improperly loaded modules
# caused from circular imports
from .title.views import title_bp  # noqa


app.config.from_pyfile("config.py")
app.register_blueprint(title_bp, url_prefix='/')
app.url_map.strict_slashes = False


@app.route("/health")
def check_status():
    return json.dumps({
        "Status": "OK",
        "headers": str(request.headers),
        "commit": str(os.getenv("COMMIT", "LOCAL"))
    })
