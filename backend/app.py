
from flask import Flask, request, jsonify
import sqlite3
import os

app = Flask(__name__)

# Database filename
DATABASE = 'habittracker.db'

def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    # This makes row retrieval behave like a dict
    conn.row_factory = sqlite3.Row
    return conn

# Ensure the database file is created if it doesn’t exist
if not os.path.exists(DATABASE):
    conn = get_db_connection()
    # Simple table to track habits
    conn.execute('''
        CREATE TABLE IF NOT EXISTS habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            habit_name TEXT NOT NULL,
            streak_count INTEGER DEFAULT 0
        )
    ''')
    
    # Table for user statistics
    conn.execute('''
        CREATE TABLE IF NOT EXISTS user_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total_habits INTEGER DEFAULT 0,
            longest_streak INTEGER DEFAULT 0,
            last_sync TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ''')
    
    # Table for users
    conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT UNIQUE NOT NULL
        )
    ''')
    # Table for friendships
    conn.execute('''
        CREATE TABLE IF NOT EXISTS friends (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            friend_id INTEGER NOT NULL
        )
    ''')
    conn.commit()
    conn.close()


@app.route('/')
def index():
    return "Welcome to the Habit Tracker API!"
    
    
#@app.route('/stats', methods=['POST'])
#def sync_stats():
#    data = request.json
#    user_id = data.get('user_id')
#    total_habits = data.get('total_habits')
#    longest_streak = data.get('longest_streak')
#
#    if user_id is None or total_habits is None or longest_streak is None:
#        return jsonify({"error": "Missing user_id, total_habits, or longest_streak"}), 400
#
#    conn = get_db_connection()
#    # Check if user_stats row exists
#    row = conn.execute('SELECT * FROM user_stats WHERE user_id = ?', (user_id,)).fetchone()
#
#    if row is None:
#        # Insert new row
#        conn.execute('''
#            INSERT INTO user_stats (user_id, total_habits, longest_streak)
#            VALUES (?, ?, ?)
#        ''', (user_id, total_habits, longest_streak))
#    else:
#        # Update existing row
#        conn.execute('''
#            UPDATE user_stats
#            SET total_habits = ?, longest_streak = ?, last_sync = CURRENT_TIMESTAMP
#            WHERE user_id = ?
#        ''', (total_habits, longest_streak, user_id))
#    
#    conn.commit()
#    conn.close()

@app.route('/stats', methods=['POST'])
def sync_stats():
    data = request.json
    user_id = data.get('user_id')
    total_habits = data.get('total_habits')
    longest_streak = data.get('longest_streak')

    if user_id is None or total_habits is None or longest_streak is None:
        return jsonify({"error": "Missing user_id, total_habits, or longest_streak"}), 400

    conn = get_db_connection()

    try:
        # Check if user_stats row exists
        row = conn.execute('SELECT * FROM user_stats WHERE user_id = ?', (user_id,)).fetchone()

        if row is None:
            # Insert new row
            conn.execute('''
                INSERT INTO user_stats (user_id, total_habits, longest_streak)
                VALUES (?, ?, ?)
            ''', (user_id, total_habits, longest_streak))
        else:
            # Update existing row
            conn.execute('''
                UPDATE user_stats
                SET total_habits = ?, longest_streak = ?, last_sync = CURRENT_TIMESTAMP
                WHERE user_id = ?
            ''', (total_habits, longest_streak, user_id))
        
        conn.commit()
        return jsonify({"message": "Stats synced successfully"}), 200  # ✅ Always return a response

    except Exception as e:
        print(f"❌ Error processing sync_stats: {e}")
        return jsonify({"error": "Internal Server Error"}), 500  # ✅ Handle errors properly
    
    finally:
        conn.close()
    
    
@app.route('/stats', methods=['GET'])
def get_stats():
    user_id = request.args.get('user_id')
    conn = get_db_connection()
    if user_id:
        # Return stats for a specific user
        stats = conn.execute('SELECT * FROM user_stats WHERE user_id = ?', (user_id,)).fetchone()
        conn.close()
        if stats is None:
            return jsonify({"error": f"No stats found for user_id {user_id}"}), 404
        return jsonify(dict(stats)), 200
    else:
        # Return stats for all users (e.g., for the leaderboard)
        stats = conn.execute('SELECT * FROM user_stats').fetchall()
        conn.close()
        result = [dict(stat) for stat in stats]
        return jsonify(result), 200


    return jsonify({"message": "Stats synced successfully"}), 200



@app.route('/habits', methods=['GET'])
def get_habits():
    user_id = request.args.get('user_id')  # e.g., /habits?user_id=2
    conn = get_db_connection()
    
    if user_id:
        # Return only that user’s habits
        habits = conn.execute(
            'SELECT * FROM habits WHERE user_id = ?',
            (user_id,)
        ).fetchall()
    else:
        # Return all habits
        habits = conn.execute('SELECT * FROM habits').fetchall()
    
    conn.close()
    habit_list = [dict(habit) for habit in habits]
    return jsonify(habit_list), 200




@app.route('/habits', methods=['POST'])
def create_habit():
    data = request.json
    user_id = data.get('user_id')
    habit_name = data.get('habit_name')

    if not user_id or not habit_name:
        return jsonify({"error": "Missing user_id or habit_name"}), 400

    conn = get_db_connection()
    conn.execute('INSERT INTO habits (user_id, habit_name, streak_count) VALUES (?, ?, 0)',
                 (user_id, habit_name))
    conn.commit()

    # Optionally fetch the newly created row to return it
    new_habit_id = conn.execute('SELECT last_insert_rowid() AS id').fetchone()['id']
    new_habit = conn.execute('SELECT * FROM habits WHERE id = ?', (new_habit_id,)).fetchone()
    conn.close()

    return jsonify(dict(new_habit)), 201



@app.route('/habits/<int:habit_id>', methods=['PUT'])
def update_habit(habit_id):
    data = request.json
    streak_count = data.get('streak_count')

    if streak_count is None:
        return jsonify({"error": "Missing streak_count"}), 400

    conn = get_db_connection()
    conn.execute('UPDATE habits SET streak_count = ? WHERE id = ?',
                 (streak_count, habit_id))
    conn.commit()
    conn.close()

    return jsonify({"message": "Habit updated successfully"}), 200


@app.route('/habits/<int:habit_id>', methods=['DELETE'])
def delete_habit(habit_id):
    conn = get_db_connection()
    conn.execute('DELETE FROM habits WHERE id = ?', (habit_id,))
    conn.commit()
    conn.close()

    return jsonify({"message": "Habit deleted successfully"}), 200


# ========== User & Friend Endpoints ==========

@app.route('/users', methods=['GET'])
def get_users():
    conn = get_db_connection()
    rows = conn.execute('SELECT * FROM users').fetchall()
    conn.close()
    users = [dict(row) for row in rows]
    return jsonify(users), 200


@app.route('/users', methods=['POST'])
def create_user():
    data = request.json
    username = data.get('username')
    if not username:
        return jsonify({"error": "Missing username"}), 400

    try:
        conn = get_db_connection()
        conn.execute('INSERT INTO users (username) VALUES (?)', (username,))
        conn.commit()
        conn.close()
        return jsonify({"message": "User created"}), 201
    except sqlite3.IntegrityError:
        # This will be raised if the username is not unique
        return jsonify({"error": "Username already exists"}), 409


@app.route('/friends', methods=['POST'])
def add_friend():
    data = request.json
    user_id = data.get('user_id')
    friend_id = data.get('friend_id')

    if not user_id or not friend_id:
        return jsonify({"error": "user_id and friend_id are required"}), 400
    
    # You can add logic to check if user_id and friend_id exist in the users table
    conn = get_db_connection()
    conn.execute('INSERT INTO friends (user_id, friend_id) VALUES (?, ?)', (user_id, friend_id))
    conn.commit()
    conn.close()

    return jsonify({"message": "Friend added"}), 201


@app.route('/leaderboard', methods=['GET'])
def leaderboard():
    """
    Leaderboard logic might just pick top users with the highest total streak_count.
    For simplicity, we’ll sum streak_count across all habits for each user.
    """
    conn = get_db_connection()
    # Summing streaks for each user
    rows = conn.execute('''
        SELECT u.username, SUM(h.streak_count) as total_streak
        FROM users u
        JOIN habits h ON u.id = h.user_id
        GROUP BY u.id
        ORDER BY total_streak DESC
    ''').fetchall()
    conn.close()

    result = []
    for row in rows:
        result.append({
            'username': row['username'],
            'total_streak': row['total_streak']
        })

    return jsonify(result), 200
    
    
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    device_id = data.get('device_id')
    if not device_id:
        return jsonify({"error": "Missing device_id"}), 400

    conn = get_db_connection()
    user = conn.execute('SELECT * FROM users WHERE device_id = ?', (device_id,)).fetchone()
    if user is None:
        # Insert new user record
        conn.execute('INSERT INTO users (device_id) VALUES (?)', (device_id,))
        conn.commit()
        user = conn.execute('SELECT * FROM users WHERE device_id = ?', (device_id,)).fetchone()
    conn.close()

    return jsonify({
        "message": "Login successful",
        "user_id": user["id"]
    }), 200



if __name__ == '__main__':
    # Run the app in debug mode for development
    app.run(debug=True, host='0.0.0.0', port=5001)
