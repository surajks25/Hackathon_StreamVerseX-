CREATE TABLE streaming_sessions (
    session_id VARCHAR(50),
    user_id INT,
    device_type VARCHAR(50),
    video_id VARCHAR(50),
    stream_quality VARCHAR(20),
    watch_duration INT,
    buffering_time FLOAT,
    session_status VARCHAR(20),
    timestamp TIMESTAMP
);

CREATE TABLE watch_history (
    watch_id VARCHAR(50),
    user_id INT,
    content_category VARCHAR(50),
    watch_time INT,
    completion_rate FLOAT,
    pause_count INT,
    skip_count INT,
    region VARCHAR(50)
);

CREATE TABLE subscription_transactions (
    transaction_id VARCHAR(50),
    user_id INT,
    plan_type VARCHAR(50),
    subscription_amount FLOAT,
    payment_mode VARCHAR(50),
    payment_status VARCHAR(20),
    renewal_status VARCHAR(20),
    timestamp TIMESTAMP
);

CREATE TABLE cdn_logs (
    cdn_event_id VARCHAR(50),
    server_region VARCHAR(50),
    latency FLOAT,
    packet_loss FLOAT,
    buffering_spike BOOLEAN,
    failure_code VARCHAR(50),
    timestamp TIMESTAMP
);

CREATE TABLE content_metadata (
    content_id VARCHAR(50),
    genre VARCHAR(50),
    release_date DATE,
    language VARCHAR(50),
    duration INT,
    rating FLOAT,
    production_studio VARCHAR(100)
);

CREATE TABLE clickstream_events (
    click_id VARCHAR(50),
    user_id INT,
    screen_name VARCHAR(100),
    click_action VARCHAR(100),
    session_duration INT,
    crash_flag BOOLEAN,
    timestamp TIMESTAMP
);

CREATE TABLE recommendation_logs (
    search_id VARCHAR(50),
    user_id INT,
    search_query VARCHAR(255),
    recommended_content VARCHAR(255),
    clicked_content VARCHAR(255),
    recommendation_score FLOAT,
    timestamp TIMESTAMP
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema='public';

SELECT COUNT(*)
FROM streaming_sessions;

SELECT *
FROM streaming_sessions
LIMIT 5;