from kafka import KafkaConsumer
import json
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="streamversex",
    user="postgres",
    password="Skulal2002",
    port="5432"
)

cursor = conn.cursor()

consumer = KafkaConsumer(
    "stream-events",
    bootstrap_servers="localhost:9092",
    auto_offset_reset="earliest",
    value_deserializer=lambda x: json.loads(x.decode("utf-8"))
)

print("🎧 Listening for events...\n")

for message in consumer:

    event = message.value

    print("Received:", event)

    try:

        cursor.execute("""
        INSERT INTO streaming_sessions(
            session_id,
            user_id,
            device_type,
            video_id,
            stream_quality,
            watch_duration,
            buffering_time,
            session_status,
            timestamp
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            event["Session_ID"],
            event["User_ID"],
            event["Device_Type"],
            event["Video_ID"],
            event["Stream_Quality"],
            event["Watch_Duration"],
            event["Buffering_Time"],
            event["Session_Status"],
            event["Timestamp"]
        ))

        conn.commit()
        print("✅ Inserted into PostgreSQL")

    except Exception as e:
        conn.rollback()
        print("❌ Error:", e)