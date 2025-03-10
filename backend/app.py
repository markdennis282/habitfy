
from flask import Flask, request, jsonify
import sqlite3
import os

app = Flask(__name__)

DATABASE = 'habittracker.db'


#
def get_db_connection():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

#create tables if database doesnt exist
if not os.path.exists(DATABASE):
    conn = get_db_connection()
    conn.execute('''
        CREATE TABLE IF NOT EXISTS habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            habit_name TEXT NOT NULL,
            streak_count INTEGER DEFAULT 0
        )
    ''')
    
    conn.execute('''
        CREATE TABLE IF NOT EXISTS user_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL UNIQUE,
            total_habits INTEGER DEFAULT 0,
            longest_streak INTEGER DEFAULT 0,
            last_sync TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ''')
    

    conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT UNIQUE NOT NULL,
            name TEXT
        )
    ''')
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
    
    #update or create new stats
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
        row = conn.execute('SELECT * FROM user_stats WHERE user_id = ?', (user_id,)).fetchone()

        if row is None:
            conn.execute('''
                INSERT INTO user_stats (user_id, total_habits, longest_streak)
                VALUES (?, ?, ?)
            ''', (user_id, total_habits, longest_streak))
        else:
            conn.execute('''
                UPDATE user_stats
                SET total_habits = ?, longest_streak = ?, last_sync = CURRENT_TIMESTAMP
                WHERE user_id = ?
            ''', (total_habits, longest_streak, user_id))
        
        conn.commit()
        return jsonify({"message": "Stats synced successfully"}), 200

    except Exception as e:
        print(f"❌ Error processing sync_stats: {e}")
        return jsonify({"error": "Internal Server Error"}), 500
    
    finally:
        conn.close()
    
    
@app.route('/stats', methods=['GET'])
def get_stats():
    user_id = request.args.get('user_id')
    conn = get_db_connection()
    if user_id:
        stats = conn.execute('SELECT * FROM user_stats WHERE user_id = ?', (user_id,)).fetchone()
        conn.close()
        if stats is None:
            return jsonify({"error": f"No stats found for user_id {user_id}"}), 404
        return jsonify(dict(stats)), 200
    else:
        stats = conn.execute('SELECT * FROM user_stats').fetchall()
        conn.close()
        result = [dict(stat) for stat in stats]
        return jsonify(result), 200


    return jsonify({"message": "Stats synced successfully"}), 200
      
@app.route('/friends/<user_id>', methods=['GET'])
def get_friends(user_id):
    conn = get_db_connection()
    rows = conn.execute('''
        SELECT DISTINCT users.id, COALESCE(users.name, users.device_id) as display_name
        FROM users
        JOIN friends ON users.id = friends.friend_id
        WHERE friends.user_id = ?
    ''', (user_id,)).fetchall()
    conn.close()

    friends = [{"id": row["id"], "name": row["display_name"]} for row in rows]
    return jsonify(friends), 200


@app.route('/leaderboard/<int:user_id>', methods=['GET'])
def get_leaderboard(user_id):
    conn = get_db_connection()
    
    rows = conn.execute('''
        SELECT
            users.id,
            COALESCE(users.name, users.device_id) AS display_name,
            COALESCE(user_stats.longest_streak, 0) AS longest_streak,
            COALESCE(user_stats.total_habits, 0) AS total_habits
        FROM users
        LEFT JOIN user_stats ON users.device_id = user_stats.user_id
        WHERE users.id = ?
           OR users.id IN (
               SELECT friend_id
               FROM friends
               JOIN users ON friends.user_id = users.device_id
               WHERE users.id = ?
           )
        ORDER BY longest_streak DESC
    ''', (user_id, user_id)).fetchall()
    
    conn.close()

    leaderboard = [
        {
            "id": row["id"],
            "name": row["display_name"],
            "longest_streak": row["longest_streak"],
            "total_habits": row["total_habits"]
        }
        for row in rows
    ]
    
    return jsonify(leaderboard), 200


@app.route('/friends/add', methods=['POST'])
def add_friend():
    data = request.json
    user_id = data.get("user_id")
    friend_id = data.get("friend_id")

    if not user_id or not friend_id:
        return jsonify({"error": "Missing user_id or friend_id"}), 400

    conn = get_db_connection()

    friend_row = conn.execute('SELECT id FROM users WHERE id = ?', (friend_id,)).fetchone()
    
    if not friend_row:
        return jsonify({"error": "Friend ID not found"}), 404

    conn.execute('INSERT INTO friends (user_id, friend_id) VALUES (?, ?)', (user_id, friend_id))
    conn.commit()
    conn.close()

    return jsonify({"message": "Friend added successfully"}), 200
    
    
@app.route('/friends/remove', methods=['POST'])
def remove_friend():
    data = request.json
    user_id = data.get("user_id")
    friend_id = data.get("friend_id")

    if not user_id or not friend_id:
        return jsonify({"error": "Missing user_id or friend_id"}), 400

    conn = get_db_connection()

    row = conn.execute('''
        SELECT id FROM friends
        WHERE user_id = ? AND friend_id = ?
    ''', (user_id, friend_id)).fetchone()

    if not row:
        conn.close()
        return jsonify({"error": "Friendship not found"}), 404

    conn.execute('DELETE FROM friends WHERE user_id = ? AND friend_id = ?', (user_id, friend_id))
    conn.commit()
    conn.close()

    return jsonify({"message": "Friend removed successfully"}), 200




@app.route('/habits', methods=['GET'])
def get_habits():
    user_id = request.args.get('user_id')
    conn = get_db_connection()
    
    if user_id:
        habits = conn.execute(
            'SELECT * FROM habits WHERE user_id = ?',
            (user_id,)
        ).fetchall()
    else:
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
        return jsonify({"error": "Username already exists"}), 409



@app.route('/login', methods=['POST'])
def login():
    data = request.json
    device_id = data.get("device_id")
    name = data.get("name", "Demo User")

    if not device_id:
        return jsonify({"error": "Missing device_id"}), 400

    conn = get_db_connection()
    user = conn.execute('SELECT id FROM users WHERE device_id = ?', (device_id,)).fetchone()
    if user:
        conn.execute('UPDATE users SET name = ? WHERE device_id = ?', (name, device_id))
        numeric_id = user["id"]
    else:
        cur = conn.execute('INSERT INTO users (device_id, name) VALUES (?, ?)', (device_id, name))
        numeric_id = cur.lastrowid
    conn.commit()
    conn.close()

    return jsonify({"message": "Login successful", "user_id": numeric_id})



@app.route('/user/id', methods=['GET'])
def get_user_id():
    uuid = request.args.get('uuid')
    if not uuid:
        return jsonify({"error": "UUID is required"}), 400

    conn = get_db_connection()
    row = conn.execute('SELECT id FROM users WHERE device_id = ?', (uuid,)).fetchone()
    conn.close()

    if row:
        return jsonify({"id": row["id"]}), 200
    else:
        return jsonify({"error": "User not found"}), 404

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
