from flask import Flask
from flask import Flask, render_template, redirect, url_for

app = Flask(__name__)


@app.route("/")
def home():
    #return render_template('home.html')
    return redirect(url_for('login'))

@app.route("/login")
def login():
    return render_template('login.html')

@app.route("/register")
def register():
    return render_template('register.html')