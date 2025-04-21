import sqlite3
from werkzeug.security import generate_password_hash

db_name = "carpool.db"

# Connect to database
conn = sqlite3.connect(db_name)
cursor = conn.cursor()

# Get all users with plain text passwords
cursor.execute("SELECT id, password FROM users")
users = cursor.fetchall()

for user in users:
    user_id = user[0]
    plain_text_password = user[1]

    # Check if the password is already hashed (hashed passwords contain "$")
    if "$" not in plain_text_password:
        hashed_password = generate_password_hash(plain_text_password)
        cursor.execute("UPDATE users SET password = ? WHERE id = ?", (hashed_password, user_id))

# Commit changes and close connection
conn.commit()
conn.close()

print("All plain text passwords have been updated to hashed passwords!")
