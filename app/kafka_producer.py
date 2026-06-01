from kafka import KafkaProducer
import json

producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

event = {
    "user_id": 101,
    "content_id": "MOV123",
    "watch_time": 120
}

producer.send("stream-events", event)
producer.flush()

print("Event Sent Successfully")