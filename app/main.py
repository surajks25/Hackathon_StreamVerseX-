from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.database import engine

app = FastAPI()

# ---------------------------------
# CORS
# ---------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------
# HOME
# ---------------------------------

@app.get("/")
def home():
    return {
        "project": "StreamVerseX",
        "status": "running"
    }


# ---------------------------------
# DATABASE TEST
# ---------------------------------

@app.get("/test-db")
def test_database():

    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))

        return {
            "database": "connected"
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# STREAMING SESSION COUNT
# ---------------------------------

@app.get("/streaming/count")
def streaming_count():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT COUNT(*)
                FROM streaming_sessions
                """)
            )

            count = result.scalar()

        return {
            "streaming_sessions_count": count
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# LIVE STREAMS
# ---------------------------------

@app.get("/streaming/live")
def live_streams():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT COUNT(*)
                FROM streaming_sessions
                """)
            )

            active_streams = result.scalar()

        return {
            "active_streams": active_streams
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# BUFFERING ANALYTICS
# ---------------------------------

@app.get("/streaming/buffering")
def buffering():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT AVG(latency)
                FROM cdn_buffering_logs
                """)
            )

            avg_latency = result.scalar()

        return {
            "average_latency": round(avg_latency, 2)
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# TOTAL USERS
# ---------------------------------

@app.get("/users/count")
def users_count():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT COUNT(DISTINCT user_id)
                FROM user_watch_history
                """)
            )

            total_users = result.scalar()

        return {
            "total_users": total_users
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# WATCH EVENTS
# ---------------------------------

@app.get("/watch-events/count")
def watch_events():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT COUNT(*)
                FROM user_watch_history
                """)
            )

            watch_events = result.scalar()

        return {
            "watch_events": watch_events
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# SUBSCRIPTIONS COUNT
# ---------------------------------

@app.get("/subscriptions/count")
def subscriptions_count():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT COUNT(*)
                FROM subscription_transactions
                """)
            )

            subscriptions = result.scalar()

        return {
            "subscriptions": subscriptions
        }

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# TRENDING CONTENT
# ---------------------------------

@app.get("/trending")
def trending():

    try:

        query = """
        SELECT content_category,
               COUNT(*) AS total_views
        FROM user_watch_history
        GROUP BY content_category
        ORDER BY total_views DESC
        LIMIT 10
        """

        with engine.connect() as conn:

            result = conn.execute(text(query))

            data = []

            for row in result:
                data.append({
                    "category": row[0],
                    "views": row[1]
                })

        return data

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# WATCH HISTORY
# ---------------------------------

@app.get("/watch-history")
def watch_history():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT *
                FROM user_watch_history
                LIMIT 50
                """)
            )

            history = []

            for row in result:
                history.append(dict(row._mapping))

        return history

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# SUBSCRIPTIONS
# ---------------------------------

@app.get("/subscriptions")
def subscriptions():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT *
                FROM subscription_transactions
                LIMIT 50
                """)
            )

            subscriptions = []

            for row in result:
                subscriptions.append(dict(row._mapping))

        return subscriptions

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# CONTENT METADATA
# ---------------------------------

@app.get("/content")
def content():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT *
                FROM content_metadata
                LIMIT 50
                """)
            )

            content_list = []

            for row in result:
                content_list.append(dict(row._mapping))

        return content_list

    except Exception as e:
        return {
            "error": str(e)
        }


# ---------------------------------
# RECOMMENDATIONS
# ---------------------------------

@app.get("/recommendations")
def recommendations():

    try:
        with engine.connect() as conn:

            result = conn.execute(
                text("""
                SELECT *
                FROM fact_recommendations
                LIMIT 50
                """)
            )

            recs = []

            for row in result:
                recs.append(dict(row._mapping))

        return recs

    except Exception as e:
        return {
            "error": str(e)
        }