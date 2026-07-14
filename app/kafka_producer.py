from kafka import KafkaProducer
import pandas as pd
import json
import time
import uuid

producer = KafkaProducer(
    bootstrap_servers="localhost:9092",
    value_serializer=lambda x: json.dumps(x).encode("utf-8")
)

# Read dataset
df = pd.read_csv("dataset/video_streaming_sessions.csv")

print("🚀 Starting Kafka Producer...\n")

for _, row in df.iterrows():

    event = row.to_dict()

    # Generate a NEW unique Session_ID
    event["Session_ID"] = f"SES{uuid.uuid4().hex[:12].upper()}"

    producer.send("stream-events", value=event)
    producer.flush()

    print(f"Sent Event: {event}")

    time.sleep(1)

print("\n✅ All events sent.")