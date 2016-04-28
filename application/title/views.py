import logging
from flask import Blueprint


LOGGER = logging.getLogger(__name__)

deed_bp = Blueprint('title', __name__,
                    template_folder='templates',
                    static_folder='static')


