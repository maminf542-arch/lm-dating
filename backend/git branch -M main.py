from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3
from typing import Optional

app = FastAPI(title="L.M Dating API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключение к базе данных SQLite
DB_NAME = "database.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    # Таблица пользователей
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            city TEXT NOT NULL,
            bio TEXT,
            gender TEXT,
            password TEXT NOT NULL
        )
    ''')
    # Таблица сообщений
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_id INTEGER,
            receiver_id INTEGER,
            text TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    
    # Добавим тестовых пользователей, если база пуста
    cursor.execute("SELECT COUNT(*) FROM users")
    if cursor.fetchone()[0] == 0:
        sample_users = [
            ("Лина", 32, "Бугуруслан", "Привет! Люблю уют, путешествия и хороший кофе ☕", "female", "12345"),
            ("Алексей", 30, "Самара", "Смотрю кино, занимаюсь техникой, ищу интересного собеседника", "male", "12345"),
            ("Елена", 28, "Оренбург", "Фотограф и романтик 📸", "female", "12345")
        ]
        cursor.executemany("INSERT INTO users (name, age, city, bio, gender, password) VALUES (?, ?, ?, ?, ?, ?)", sample_users)
        conn.commit()
    conn.close()

init_db()

class UserRegister(BaseModel):
    name: str
    age: int
    city: str
    bio: Optional[str] = ""
    gender: str
    password: str

class UserLogin(BaseModel):
    name: str
    password: str

class MessageSend(BaseModel):
    sender_id: int
    receiver_id: int
    text: str

@post("/api/register")
def register(user: UserRegister):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE name = ?", (user.name,))
    if cursor.fetchone():
        conn.close()
        raise HTTPException(status_code=400, detail="Пользователь с таким именем уже существует")
    
    cursor.execute(
        "INSERT INTO users (name, age, city, bio, gender, password) VALUES (?, ?, ?, ?, ?, ?)",
        (user.name, user.age, user.city, user.bio, user.gender, user.password)
    )
    conn.commit()
    user_id = cursor.lastrowid
    conn.close()
    return {"status": "success", "user_id": user_id, "message": "Регистрация успешна!"}

@post("/api/login")
def login(data: UserLogin):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, age, city, bio, gender FROM users WHERE name = ? AND password = ?", (data.name, data.password))
    row = cursor.fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=400, detail="Неверное имя или пароль")
    
    return {
        "status": "success",
        "user": {"id": row[0], "name": row[1], "age": row[2], "city": row[3], "bio": row[4], "gender": row[5]}
    }

@get("/api/users/radar")
def get_radar_users(exclude_id: int = 0):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, age, city, bio FROM users WHERE id != ?", (exclude_id,))
    rows = cursor.fetchall()
    conn.close()
    
    users_list = []
    for r in rows:
        users_list.append({
            "id": r[0],
            "name": r[1],
            "age": r[2],
            "city": r[3],
            "bio": r[4] or "Без описания",
            "distance": "1.2 км от вас"
        })
    return {"users": users_list}

@post("/api/messages/send")
def send_message(msg: MessageSend):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO messages (sender_id, receiver_id, text) VALUES (?, ?, ?)", (msg.sender_id, msg.receiver_id, msg.text))
    conn.commit()
    conn.close()
    return {"status": "sent"}

@get("/api/messages/history")
def get_history(user1: int, user2: int):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("""
        SELECT sender_id, text, timestamp FROM messages 
        WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
        ORDER BY timestamp ASC
    """, (user1, user2, user2, user1))
    rows = cursor.fetchall()
    conn.close()
    
    messages = [{"sender_id": r[0], "text": r[1], "time": r[2]} for r in rows]
    return {"messages": messages}