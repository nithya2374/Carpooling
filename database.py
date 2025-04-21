import sqlite3

def get_db_connection():
    conn = sqlite3.connect('carpool.db')  # Replace with the actual path to your SQLite DB
    conn.row_factory = sqlite3.Row  # Allows us to access columns by name (like a dictionary)
    return conn

def get_user_by_email(email):
    conn = get_db_connection()
    user = conn.execute('SELECT * FROM users WHERE email = ?', (email,)).fetchone()
    conn.close()
    return user
