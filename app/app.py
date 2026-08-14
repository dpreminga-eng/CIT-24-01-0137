import os
import time
import psycopg2
from flask import Flask, request, redirect, render_template

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST", "db")
DB_NAME = os.environ.get("DB_NAME", "notesdb")
DB_USER = os.environ.get("DB_USER", "notesuser")
DB_PASS = os.environ.get("DB_PASS", "notespass")


def get_connection():
    """Connect to Postgres, retrying a few times in case the DB
    container is still starting up."""
    attempts = 0
    while attempts < 10:
        try:
            conn = psycopg2.connect(
                host=DB_HOST,
                dbname=DB_NAME,
                user=DB_USER,
                password=DB_PASS,
            )
            return conn
        except psycopg2.OperationalError:
            attempts += 1
            time.sleep(3)
    raise Exception("Could not connect to the database after several attempts")


def init_db():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS notes (
            id SERIAL PRIMARY KEY,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        );
        """
    )
    conn.commit()
    cur.close()
    conn.close()


@app.route("/", methods=["GET"])
def index():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, content, created_at FROM notes ORDER BY id DESC;")
    notes = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("index.html", notes=notes)


@app.route("/add", methods=["POST"])
def add_note():
    content = request.form.get("content", "").strip()
    if content:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO notes (content) VALUES (%s);", (content,))
        conn.commit()
        cur.close()
        conn.close()
    return redirect("/")


@app.route("/delete/<int:note_id>", methods=["POST"])
def delete_note(note_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM notes WHERE id = %s;", (note_id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect("/")


@app.route("/health", methods=["GET"])
def health():
    return {"status": "ok"}, 200


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
