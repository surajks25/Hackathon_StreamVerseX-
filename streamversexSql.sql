SELECT current_database();

SELECT COUNT(*) FROM streaming_sessions;

SELECT * FROM pg_stat_activity;

CREATE TABLE app_clickstream_events (
    click_id VARCHAR(20) PRIMARY KEY,
    user_id INTEGER,
    screen_name VARCHAR(100),
    click_action VARCHAR(50),
    session_duration INTEGER,
    crash_flag BOOLEAN,
    timestamp TIMESTAMP
);

CREATE TABLE cdn_buffering_logs (
    cdn_event_id VARCHAR(20) PRIMARY KEY,
    server_region VARCHAR(50),
    latency NUMERIC(10,2),
    packet_loss NUMERIC(10,2),
    buffering_spike BOOLEAN,
    failure_code INTEGER,
    timestamp TIMESTAMP
);

CREATE TABLE content_metadata (
    content_id VARCHAR(20) PRIMARY KEY,
    genre VARCHAR(50),
    release_date DATE,
    language VARCHAR(50),
    duration INTEGER,
    rating NUMERIC(3,1),
    production_studio VARCHAR(100)
);

CREATE TABLE search_recommendation_logs (
    search_id VARCHAR(20) PRIMARY KEY,
    user_id INTEGER,
    search_query VARCHAR(255),
    recommended_content VARCHAR(20),
    clicked_content VARCHAR(20),
    recommendation_score NUMERIC(4,2),
    timestamp TIMESTAMP
);

CREATE TABLE subscription_transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    user_id INTEGER,
    plan_type VARCHAR(50),
    subscription_amount NUMERIC(10,2),
    payment_mode VARCHAR(50),
    payment_status VARCHAR(50),
    renewal_status VARCHAR(50),
    timestamp TIMESTAMP
);

CREATE TABLE user_watch_history (
    watch_id VARCHAR(20) PRIMARY KEY,
    user_id INTEGER,
    content_category VARCHAR(50),
    watch_time INTEGER,
    completion_rate NUMERIC(5,2),
    pause_count INTEGER,
    skip_count INTEGER,
    region VARCHAR(50)
);

CREATE TABLE streaming_sessions (
    session_id VARCHAR(20) PRIMARY KEY,
    user_id INTEGER,
    device_type VARCHAR(50),
    video_id VARCHAR(20),
    stream_quality VARCHAR(20),
    watch_duration INTEGER,
    buffering_time NUMERIC(10,2),
    session_status VARCHAR(50),
    timestamp TIMESTAMP
);




SELECT 'app_clickstream_events', COUNT(*) FROM app_clickstream_events
UNION ALL
SELECT 'cdn_buffering_logs', COUNT(*) FROM cdn_buffering_logs
UNION ALL
SELECT 'content_metadata', COUNT(*) FROM content_metadata
UNION ALL
SELECT 'search_recommendation_logs', COUNT(*) FROM search_recommendation_logs
UNION ALL
SELECT 'subscription_transactions', COUNT(*) FROM subscription_transactions
UNION ALL
SELECT 'user_watch_history', COUNT(*) FROM user_watch_history
UNION ALL
SELECT 'streaming_sessions', COUNT(*) FROM streaming_sessions;


SELECT * FROM streaming_sessions LIMIT 5;

SELECT * FROM user_watch_history LIMIT 5;

SELECT * FROM content_metadata LIMIT 5;


CREATE INDEX idx_stream_user
ON streaming_sessions(user_id);

CREATE INDEX idx_watch_user
ON user_watch_history(user_id);

CREATE INDEX idx_sub_user
ON subscription_transactions(user_id);

CREATE INDEX idx_search_user
ON search_recommendation_logs(user_id);




SELECT DISTINCT device_type
FROM streaming_sessions
ORDER BY device_type;


SELECT DISTINCT region
FROM user_watch_history
ORDER BY region;

SELECT COUNT(DISTINCT user_id)
FROM streaming_sessions;


SELECT COUNT(DISTINCT video_id)
FROM streaming_sessions;

SELECT COUNT(*)
FROM content_metadata;

CREATE TABLE dim_device AS
SELECT DISTINCT
    device_type
FROM streaming_sessions;

CREATE TABLE dim_region AS
SELECT DISTINCT
    region
FROM user_watch_history;

CREATE TABLE dim_user AS
SELECT DISTINCT
    user_id
FROM streaming_sessions;

CREATE TABLE dim_content AS
SELECT DISTINCT
    video_id AS content_id
FROM streaming_sessions;





SELECT COUNT(*) FROM dim_device;
SELECT COUNT(*) FROM dim_region;
SELECT COUNT(*) FROM dim_user;
SELECT COUNT(*) FROM dim_content;


CREATE TABLE fact_streaming_sessions AS
SELECT
    session_id,
    user_id,
    video_id,
    device_type,
    watch_duration,
    buffering_time,
    session_status,
    timestamp
FROM streaming_sessions;


CREATE TABLE fact_watch_history AS
SELECT
    watch_id,
    user_id,
    content_category,
    watch_time,
    completion_rate,
    pause_count,
    skip_count,
    region
FROM user_watch_history;


CREATE TABLE fact_subscriptions AS
SELECT
    transaction_id,
    user_id,
    plan_type,
    subscription_amount,
    payment_status,
    renewal_status,
    timestamp
FROM subscription_transactions;


CREATE TABLE fact_clickstream AS
SELECT
    click_id,
    user_id,
    screen_name,
    click_action,
    session_duration,
    crash_flag,
    timestamp
FROM app_clickstream_events;


CREATE TABLE fact_recommendations AS
SELECT
    search_id,
    user_id,
    search_query,
    recommended_content,
    clicked_content,
    recommendation_score,
    timestamp
FROM search_recommendation_logs;



SELECT COUNT(*) FROM fact_streaming_sessions;
SELECT COUNT(*) FROM fact_clickstream;
SELECT COUNT(*) FROM fact_recommendations;



CREATE TABLE dim_date AS
SELECT DISTINCT
    DATE(timestamp) AS full_date,
    EXTRACT(YEAR FROM timestamp) AS year,
    EXTRACT(MONTH FROM timestamp) AS month,
    EXTRACT(DAY FROM timestamp) AS day,
    EXTRACT(QUARTER FROM timestamp) AS quarter
FROM fact_streaming_sessions;


SELECT COUNT(*) FROM dim_date;


ALTER TABLE dim_user
ADD COLUMN user_key SERIAL;

ALTER TABLE dim_user
ADD PRIMARY KEY (user_key);

ALTER TABLE dim_device
ADD COLUMN device_key SERIAL;

ALTER TABLE dim_device
ADD PRIMARY KEY (device_key);

ALTER TABLE dim_region
ADD COLUMN region_key SERIAL;

ALTER TABLE dim_region
ADD PRIMARY KEY (region_key);

ALTER TABLE dim_content
ADD COLUMN content_key SERIAL;

ALTER TABLE dim_content
ADD PRIMARY KEY (content_key);

ALTER TABLE dim_date
ADD COLUMN date_key SERIAL;

ALTER TABLE dim_date
ADD PRIMARY KEY (date_key);

SELECT * FROM dim_device;

SELECT * FROM dim_user LIMIT 5;
SELECT * FROM dim_device;
SELECT * FROM dim_region;
SELECT * FROM dim_content LIMIT 5;
SELECT * FROM dim_date LIMIT 5;

SELECT * FROM dim_user LIMIT 5;

SELECT * FROM dim_region;


CREATE TABLE fact_streaming_sessions_dw AS
SELECT
    fs.session_id,
    du.user_key,
    dd.device_key,
    ddt.date_key,
    fs.watch_duration,
    fs.buffering_time,
    fs.session_status
FROM fact_streaming_sessions fs
JOIN dim_user du
    ON fs.user_id = du.user_id
JOIN dim_device dd
    ON fs.device_type = dd.device_type
JOIN dim_date ddt
    ON DATE(fs.timestamp) = ddt.full_date;


SELECT COUNT(*)
FROM fact_streaming_sessions_dw;

CREATE TABLE fact_subscriptions_dw AS
SELECT
    fs.transaction_id,
    du.user_key,
    ddt.date_key,
    fs.plan_type,
    fs.subscription_amount,
    fs.payment_status,
    fs.renewal_status
FROM fact_subscriptions fs
JOIN dim_user du
    ON fs.user_id = du.user_id
JOIN dim_date ddt
    ON DATE(fs.timestamp) = ddt.full_date;

CREATE TABLE fact_clickstream_dw AS
SELECT
    fc.click_id,
    du.user_key,
    ddt.date_key,
    fc.screen_name,
    fc.click_action,
    fc.session_duration,
    fc.crash_flag
FROM fact_clickstream fc
JOIN dim_user du
    ON fc.user_id = du.user_id
JOIN dim_date ddt
    ON DATE(fc.timestamp) = ddt.full_date;



CREATE TABLE fact_recommendations_dw AS
SELECT
    fr.search_id,
    du.user_key,
    ddt.date_key,
    fr.search_query,
    fr.recommended_content,
    fr.clicked_content,
    fr.recommendation_score
FROM fact_recommendations fr
JOIN dim_user du
    ON fr.user_id = du.user_id
JOIN dim_date ddt
    ON DATE(fr.timestamp) = ddt.full_date;

	CREATE TABLE fact_watch_history_dw AS
SELECT
    fwh.watch_id,
    du.user_key,
    dr.region_key,
    fwh.watch_time,
    fwh.completion_rate,
    fwh.pause_count,
    fwh.skip_count,
    fwh.content_category
FROM fact_watch_history fwh
JOIN dim_user du
    ON fwh.user_id = du.user_id
JOIN dim_region dr
    ON fwh.region = dr.region;


SELECT COUNT(*) FROM fact_subscriptions_dw;
SELECT COUNT(*) FROM fact_clickstream_dw;
SELECT COUNT(*) FROM fact_recommendations_dw;
SELECT COUNT(*) FROM fact_watch_history_dw;





SELECT COUNT(*) FROM dim_date;


SELECT MIN(DATE(timestamp)),
       MAX(DATE(timestamp))
FROM streaming_sessions;

SELECT MIN(full_date),
       MAX(full_date)
FROM dim_date;


SELECT COUNT(*)
FROM fact_streaming_sessions
WHERE timestamp IS NULL;


SELECT COUNT(*) FROM dim_user;

SELECT COUNT(DISTINCT user_id)
FROM (
    SELECT user_id FROM streaming_sessions
    UNION
    SELECT user_id FROM user_watch_history
    UNION
    SELECT user_id FROM subscription_transactions
    UNION
    SELECT user_id FROM app_clickstream_events
    UNION
    SELECT user_id FROM search_recommendation_logs
) t;

SELECT COUNT(DISTINCT user_id)
FROM (
    SELECT user_id FROM streaming_sessions
    UNION
    SELECT user_id FROM user_watch_history
    UNION
    SELECT user_id FROM subscription_transactions
    UNION
    SELECT user_id FROM app_clickstream_events
    UNION
    SELECT user_id FROM search_recommendation_logs
) t;
SELECT COUNT(*) FROM dim_user;


SELECT *
FROM cdn_buffering_logs
LIMIT 5;

SELECT AVG(buffering_duration_ms)
FROM cdn_buffering_logs

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'cdn_buffering_logs';

SELECT content_id,
       COUNT(*) AS total_views
FROM user_watch_history
GROUP BY content_id

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'user_watch_history';

CREATE TABLE audit_log(
    log_id SERIAL PRIMARY KEY,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR(20)
);

SELECT trigger_name,
       event_object_table
FROM information_schema.triggers;

CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log(action_type)
    VALUES (TG_OP);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log(action_type)
    VALUES (TG_OP);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER subscription_audit_trigger
AFTER INSERT OR UPDATE OR DELETE
ON subscription_transactions
FOR EACH ROW
EXECUTE FUNCTION log_changes();

SELECT trigger_name, event_object_table
FROM information_schema.triggers;

UPDATE subscription_transactions
SET payment_status = payment_status;

SELECT * FROM audit_log;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'fact_streaming_sessions';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'content_metadata';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='dim_user';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='fact_subscriptions';

SELECT COUNT(*),
       COUNT(DISTINCT user_id)
FROM dim_user;

SELECT COUNT(*) FROM streaming_sessions;

SELECT COUNT(*) FROM user_watch_history;

SELECT COUNT(*) FROM subscription_transactions;

SELECT COUNT(*) FROM dim_user;

SELECT COUNT(*) FROM streaming_sessions;

SELECT COUNT(*) FROM streaming_sessions;

DROP TABLE dim_user;

CREATE TABLE dim_user AS
SELECT DISTINCT
    user_id
FROM streaming_sessions;

SELECT COUNT(*) FROM dim_user;

ALTER TABLE dim_user
ADD COLUMN user_key SERIAL;

ALTER TABLE dim_user
ADD PRIMARY KEY (user_key);

SELECT COUNT(*) FROM dim_user;

SELECT COUNT(*) FROM streaming_sessions;

SELECT COUNT(*) FROM dim_user;
SELECT COUNT(*) FROM dim_device;
SELECT COUNT(*) FROM dim_region;
SELECT COUNT(*) FROM dim_content;
SELECT COUNT(*) FROM dim_date;

SELECT COUNT(*) FROM streaming_sessions;

SELECT COUNT(*) FROM user_watch_history;

SELECT COUNT(*) FROM content_metadata;

SELECT COUNT(DISTINCT device_type)
FROM streaming_sessions;

SELECT COUNT(DISTINCT region)
FROM user_watch_history;

SELECT COUNT(DISTINCT video_id)
FROM streaming_sessions;

DROP TABLE IF EXISTS dim_device CASCADE;
DROP TABLE IF EXISTS dim_region CASCADE;
DROP TABLE IF EXISTS dim_content CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_device AS
SELECT DISTINCT device_type
FROM streaming_sessions;

CREATE TABLE dim_region AS
SELECT DISTINCT region
FROM user_watch_history;

CREATE TABLE dim_content AS
SELECT DISTINCT video_id AS content_id
FROM streaming_sessions;

CREATE TABLE dim_date AS
SELECT DISTINCT
    DATE(timestamp) AS full_date,
    EXTRACT(YEAR FROM timestamp) AS year,
    EXTRACT(MONTH FROM timestamp) AS month,
    EXTRACT(DAY FROM timestamp) AS day,
    EXTRACT(QUARTER FROM timestamp) AS quarter
FROM streaming_sessions;

SELECT COUNT(*) FROM dim_device;
SELECT COUNT(*) FROM dim_region;
SELECT COUNT(*) FROM dim_content;
SELECT COUNT(*) FROM dim_date;

SELECT COUNT(*) FROM dim_user;
SELECT COUNT(*) FROM dim_device;
SELECT COUNT(*) FROM dim_region;
SELECT COUNT(*) FROM dim_content;
SELECT COUNT(*) FROM dim_date;

SELECT COUNT(*) FROM fact_streaming_sessions_dw;
SELECT COUNT(*) FROM fact_subscriptions_dw;
SELECT COUNT(*) FROM fact_clickstream_dw;
SELECT COUNT(*) FROM fact_recommendations_dw;
SELECT COUNT(*) FROM fact_watch_history_dw;

DROP TABLE IF EXISTS fact_streaming_sessions_dw;

SELECT *
FROM dim_device
LIMIT 5;

ALTER TABLE dim_device
ADD COLUMN device_key SERIAL;

SELECT * FROM dim_device;

SELECT * FROM dim_user LIMIT 5;
SELECT * FROM dim_region LIMIT 5;
SELECT * FROM dim_content LIMIT 5;
SELECT * FROM dim_date LIMIT 5;

SELECT * FROM dim_date LIMIT 5;

SELECT * FROM dim_device LIMIT 5;

SELECT * FROM dim_user LIMIT 5;

CREATE TABLE fact_streaming_sessions_dw AS
SELECT
    fs.session_id,
    du.user_key,
    dd.device_key,
    ddt.full_date,
    fs.watch_duration,
    fs.buffering_time,
    fs.session_status
FROM fact_streaming_sessions fs
JOIN dim_user du
    ON fs.user_id = du.user_id
JOIN dim_device dd
    ON fs.device_type = dd.device_type
JOIN dim_date ddt
    ON DATE(fs.timestamp) = ddt.full_date;



DROP TABLE IF EXISTS fact_subscriptions_dw;

CREATE TABLE fact_subscriptions_dw AS
SELECT
    fs.transaction_id,
    du.user_key,
    ddt.full_date,
    fs.plan_type,
    fs.subscription_amount,
    fs.payment_status,
    fs.renewal_status
FROM fact_subscriptions fs
JOIN dim_user du
    ON fs.user_id = du.user_id
JOIN dim_date ddt
    ON DATE(fs.timestamp) = ddt.full_date;



DROP TABLE IF EXISTS fact_clickstream_dw;

CREATE TABLE fact_clickstream_dw AS
SELECT
    fc.click_id,
    du.user_key,
    ddt.full_date,
    fc.screen_name,
    fc.click_action,
    fc.session_duration,
    fc.crash_flag
FROM app_clickstream_events fc
JOIN dim_user du
    ON fc.user_id = du.user_id
JOIN dim_date ddt
    ON DATE(fc.timestamp) = ddt.full_date;

DROP TABLE IF EXISTS fact_recommendations_dw;

CREATE TABLE fact_recommendations_dw AS
SELECT
    fr.search_id,
    du.user_key,
    ddt.full_date,
    fr.search_query,
    fr.recommended_content,
    fr.clicked_content,
    fr.recommendation_score
FROM fact_recommendations fr
JOIN dim_user du
    ON fr.user_id = du.user_id
JOIN dim_date ddt
    ON DATE(fr.timestamp) = ddt.full_date;

DROP TABLE IF EXISTS fact_watch_history_dw;

CREATE TABLE fact_watch_history_dw AS
SELECT
    fwh.watch_id,
    du.user_key,
    dr.region,
    fwh.watch_time,
    fwh.completion_rate,
    fwh.pause_count,
    fwh.skip_count,
    fwh.content_category
FROM fact_watch_history fwh
JOIN dim_user du
    ON fwh.user_id = du.user_id
JOIN dim_region dr
    ON fwh.region = dr.region;

SELECT * FROM dim_region LIMIT 5;

SELECT COUNT(*) FROM fact_streaming_sessions_dw;
SELECT COUNT(*) FROM fact_subscriptions_dw;
SELECT COUNT(*) FROM fact_clickstream_dw;
SELECT COUNT(*) FROM fact_recommendations_dw;
SELECT COUNT(*) FROM fact_watch_history_dw;

SELECT COUNT(*) FROM fact_clickstream;
SELECT COUNT(*) FROM dim_user;
SELECT COUNT(*) FROM dim_date;

SELECT COUNT(*) FROM fact_clickstream;
SELECT COUNT(*) FROM app_clickstream_events;
SELECT * FROM app_clickstream_events LIMIT 5;

FROM app_clickstream_events fc

SELECT * 
FROM app_clickstream_events
LIMIT 1;




