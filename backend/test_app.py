# test_app.py

import os
import pytest
import sqlite3
from flask import g
from app import app, get_db_connection
TEST_DB = ":memory:"

@pytest.fixture
def client():
    print("\n[Setup] Initializing test client and in-memory database...")
    app.config["TESTING"] = True
    def override_get_db_connection():
        if 'db_conn' not in g:
            g.db_conn = sqlite3.connect(TEST_DB)
            g.db_conn.row_factory = sqlite3.Row
        return g.db_conn

    app.testing = True
    app.view_functions['get_db_connection'] = override_get_db_connection
    app.get_db_connection = override_get_db_connection
    with app.test_client() as client:
        with app.app_context():
            conn = override_get_db_connection()
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
                    last_sync TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
        yield client


        with app.app_context():
            db = g.pop('db_conn', None)
            if db is not None:
                db.close()




def test_login_creates_user(client):
    print("\n[Test] test_login_creates_user")
    """
    Test the /login endpoint creates
    """
    payload = {
        "device_id": "test_device_123",
        "name": "Test User"
    }
    response = client.post('/login', json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["message"] == "Login successful"
    assert "user_id" in data
    user_id = data["user_id"]
    get_user_resp = client.get(f'/user/id?uuid={payload["device_id"]}')
    assert get_user_resp.status_code == 200
    found_id = get_user_resp.get_json()["id"]
    assert found_id == user_id


def test_login_updates_name_if_exists(client):
    print("\n[Test] test_login_updates_name_if_exists")
    """
    Test that /login updates
    """
    payload = {
        "device_id": "test_device_456",
        "name": "Old Name"
    }
    response = client.post('/login', json=payload)
    assert response.status_code == 200
    new_payload = {
        "device_id": "test_device_456",
        "name": "New Name"
    }
    response2 = client.post('/login', json=new_payload)
    assert response2.status_code == 200
    data2 = response2.get_json()
    assert data2["message"] == "Login successful"
    get_user_resp = client.get(f'/user/id?uuid={payload["device_id"]}')
    assert get_user_resp.status_code == 200
    user_id = get_user_resp.get_json()["id"]
    all_users_resp = client.get('/users')
    assert all_users_resp.status_code == 200
    users_list = all_users_resp.get_json()
    matched = [u for u in users_list if u['id'] == user_id]
    assert len(matched) == 1
    assert matched[0]['name'] == "New Name"


def test_sync_stats_and_get_stats(client):
    print("\n[Test] test_sync_stats_and_get_stats")
    """
    Test POST /stats  and GET /stats
    """
    payload = {
        "device_id": "test_device_stats",
        "name": "StatsUser"
    }
    response = client.post('/login', json=payload)
    assert response.status_code == 200
    user_id = response.get_json()["user_id"]
    sync_payload = {
        "user_id": user_id,
        "total_habits": 5,
        "longest_streak": 10
    }
    post_stats_resp = client.post('/stats', json=sync_payload)
    assert post_stats_resp.status_code == 200
    assert post_stats_resp.get_json()["message"] == "Stats synced successfully"
    get_stats_resp = client.get(f'/stats?user_id={user_id}')
    assert get_stats_resp.status_code == 200
    stats_data = get_stats_resp.get_json()
    assert stats_data["total_habits"] == 5
    assert stats_data["longest_streak"] == 10



def test_update_habit(client):
    print("\n[Test] test_update_habit")
    """
    Test updating a habit
    """
    login_payload = {
        "device_id": "test_device_update_habit",
        "name": "UpdateHabitUser"
    }
    resp = client.post('/login', json=login_payload)
    user_id = resp.get_json()["user_id"]
    create_resp = client.post('/habits', json={"user_id": user_id, "habit_name": "Read Book"})
    habit_id = create_resp.get_json()["id"]
    update_resp = client.put(f'/habits/{habit_id}', json={"streak_count": 7})
    assert update_resp.status_code == 200
    get_habits_resp = client.get(f'/habits?user_id={user_id}')
    assert get_habits_resp.status_code == 200
    habit_list = get_habits_resp.get_json()
    updated = [h for h in habit_list if h["id"] == habit_id][0]
    assert updated["streak_count"] == 7


def test_delete_habit(client):
    print("\n[Test] test_delete_habit")
    """
    Test deleting a habit.
    """
    resp = client.post('/login', json={"device_id": "test_delete_habit", "name": "DelHabitUser"})
    user_id = resp.get_json()["user_id"]
    create_resp = client.post('/habits', json={"user_id": user_id, "habit_name": "Jog"})
    habit_id = create_resp.get_json()["id"]
    delete_resp = client.delete(f'/habits/{habit_id}')
    assert delete_resp.status_code == 200
    get_resp = client.get(f'/habits?user_id={user_id}')
    habits = get_resp.get_json()
    assert len(habits) == 0


def test_add_and_remove_friend(client):
    print("\n[Test] test_add_and_remove_friend")
    """
    Test adding and removing a friend.
    """
    resp1 = client.post('/login', json={"device_id": "user_friend_1", "name": "FriendUser1"})
    u1_id = resp1.get_json()["user_id"]
    resp2 = client.post('/login', json={"device_id": "user_friend_2", "name": "FriendUser2"})
    u2_id = resp2.get_json()["user_id"]
    add_resp = client.post('/friends/add', json={"user_id": u1_id, "friend_id": u2_id})
    assert add_resp.status_code == 200
    get_resp = client.get(f'/friends/{u1_id}')
    assert get_resp.status_code == 200
    friends_data = get_resp.get_json()
    assert len(friends_data) == 1
    assert friends_data[0]["id"] == u2_id
    remove_resp = client.post('/friends/remove', json={"user_id": u1_id, "friend_id": u2_id})
    assert remove_resp.status_code == 200
    get_resp2 = client.get(f'/friends/{u1_id}')
    friends_data2 = get_resp2.get_json()
    assert len(friends_data2) == 0


