from flask import Flask
from flask import Flask, render_template, redirect, request, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from database import SensorData, db
from flask import jsonify

app = Flask(__name__)
CORS(app)


app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@sensor-db-postgresql:5432/postgres"
# db = SQLAlchemy(app)
db.init_app(app)

# @app.before_first_request
# def create_tables():
#     db.create_all()

@app.route("/", methods=['GET', 'POST'])
def home():
    # with app.app_context():
    db.create_all()
    sensor_data = SensorData.query.order_by(SensorData.id.desc()).limit(50).all()
    # print(sensor_data)
    return render_template('home.html',sensor_data=sensor_data)


@app.route("/data_analysis", methods=['GET', 'POST'])
def data_analysis():
    return render_template('data_analysis.html')


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)