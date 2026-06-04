  import { useEffect, useState } from "react";

  import {
    ResponsiveContainer,
    BarChart,
    Bar,
    LineChart,
    Line,
    PieChart,
    Pie,
    Cell,
    CartesianGrid,
    XAxis,
    YAxis,
    Tooltip,
  } from "recharts";

  import {
    FaUsers,
    FaTv,
    FaPlayCircle,
    FaHistory,
  } from "react-icons/fa";

  import { MdSubscriptions } from "react-icons/md";
  import { BsSpeedometer2 } from "react-icons/bs";

  function Dashboard() {
    const [sessions, setSessions] = useState(0);
    const [activeStreams, setActiveStreams] = useState(0);
    const [avgLatency, setAvgLatency] = useState(0);
    const [totalUsers, setTotalUsers] = useState(0);
    const [watchEvents, setWatchEvents] = useState(0);
    const [subscriptions, setSubscriptions] = useState(0);
    const [trendingData, setTrendingData] = useState([]);

    const liveUsersData = [
      { time: "10:00", users: 7800 },
      { time: "10:05", users: 7900 },
      { time: "10:10", users: 8000 },
      { time: "10:15", users: 8100 },
      { time: "10:20", users: 8024 },
    ];

    const streamTrendData = [
      { time: "10:00", streams: 118000 },
      { time: "10:05", streams: 118500 },
      { time: "10:10", streams: 119000 },
      { time: "10:15", streams: 119500 },
      { time: "10:20", streams: 120000 },
    ];

    const COLORS = [
      "#3b82f6",
      "#22c55e",
      "#f97316",
      "#ec4899",
      "#8b5cf6",
      "#06b6d4",
    ];

    const loadDashboard = () => {
  fetch("http://127.0.0.1:8000/streaming/count")
    .then((res) => res.json())
    .then((data) =>
      setSessions(data.streaming_sessions_count || 0)
    )
    .catch(() => setSessions(0));

  fetch("http://127.0.0.1:8000/streaming/live")
    .then((res) => res.json())
    .then((data) =>
      setActiveStreams(data.active_streams || 0)
    )
    .catch(() => setActiveStreams(0));

  fetch("http://127.0.0.1:8000/streaming/buffering")
    .then((res) => res.json())
    .then((data) =>
      setAvgLatency(data.average_latency || 0)
    )
    .catch(() => setAvgLatency(0));

  fetch("http://127.0.0.1:8000/users/count")
    .then((res) => res.json())
    .then((data) =>
      setTotalUsers(data.total_users || 0)
    )
    .catch(() => setTotalUsers(0));

  fetch("http://127.0.0.1:8000/watch-events/count")
    .then((res) => res.json())
    .then((data) =>
      setWatchEvents(data.watch_events || 0)
    )
    .catch(() => setWatchEvents(0));

  fetch("http://127.0.0.1:8000/subscriptions/count")
    .then((res) => res.json())
    .then((data) =>
      setSubscriptions(data.subscriptions || 0)
    )
    .catch(() => setSubscriptions(0));

  fetch("http://127.0.0.1:8000/trending")
    .then((res) => res.json())
    .then((data) => {
      console.log("TRENDING API:", data);

      if (Array.isArray(data)) {
        setTrendingData(data);
      } else if (data && Array.isArray(data.trending)) {
        setTrendingData(data.trending);
      } else {
        setTrendingData([]);
      }
    })
    .catch((err) => {
      console.error(err);
      setTrendingData([]);
    });
};

useEffect(() => {
  loadDashboard();

  const interval = setInterval(() => {
    loadDashboard();
  }, 5000);

  return () => clearInterval(interval);
}, []);

const safeTrendingData = Array.isArray(trendingData)
  ? trendingData
  : [];


    const cardStyle = (gradient) => ({
      background: gradient,
      borderRadius: "18px",
      padding: "25px",
      textAlign: "center",
      color: "white",
      boxShadow: "0 10px 25px rgba(0,0,0,0.4)",
    });

    return (
      <div
        style={{
          display: "flex",
          minHeight: "100vh",
          background: "#071224",
          color: "white",
        }}
      >
        <div
          style={{
            width: "240px",
            background: "#050d1a",
            padding: "25px",
            borderRight: "1px solid #1e293b",
          }}
        >
          <h2>🎬 StreamVerseX</h2>

          <div style={{ marginTop: "40px", lineHeight: "40px" }}>
            <div>📊 Dashboard</div>
            <div>⚡ Realtime Events</div>
            <div>🔥 Trending Content</div>
            <div>📺 Watch History</div>
            <div>💳 Subscriptions</div>
          </div>
        </div>

        <div style={{ flex: 1, padding: "30px" }}>
          <h1
            style={{
              textAlign: "center",
              fontSize: "55px",
            }}
          >
            StreamVerseX Analytics Platform
          </h1>

          <p
            style={{
              textAlign: "center",
              color: "#94a3b8",
            }}
          >
            Last Updated: {new Date().toLocaleTimeString()}
          </p>

          <div
            style={{
              display: "grid",
              gridTemplateColumns:
                "repeat(auto-fit,minmax(250px,1fr))",
              gap: "20px",
              marginTop: "30px",
            }}
          >
            <div style={cardStyle("linear-gradient(135deg,#2563eb,#1d4ed8)")}>
              <FaUsers size={35} />
              <h3>Total Users</h3>
              <h2>{totalUsers}</h2>
            </div>

            <div style={cardStyle("linear-gradient(135deg,#16a34a,#15803d)")}>
              <FaPlayCircle size={35} />
              <h3>Active Streams</h3>
              <h2>{activeStreams}</h2>
            </div>

            <div style={cardStyle("linear-gradient(135deg,#7c3aed,#6d28d9)")}>
              <FaTv size={35} />
              <h3>Streaming Sessions</h3>
              <h2>{sessions}</h2>
            </div>

            <div style={cardStyle("linear-gradient(135deg,#ea580c,#c2410c)")}>
              <FaHistory size={35} />
              <h3>Watch Events</h3>
              <h2>{watchEvents}</h2>
            </div>

            <div style={cardStyle("linear-gradient(135deg,#0891b2,#0e7490)")}>
              <MdSubscriptions size={35} />
              <h3>Subscriptions</h3>
              <h2>{subscriptions}</h2>
            </div>

            <div style={cardStyle("linear-gradient(135deg,#db2777,#be185d)")}>
              <BsSpeedometer2 size={35} />
              <h3>Average Latency</h3>
              <h2>{avgLatency} ms</h2>
            </div>
          </div>

          <div
            style={{
              marginTop: "40px",
              background: "#111827",
              padding: "20px",
              borderRadius: "20px",
            }}
          >
            <h2>🔥 Trending Categories</h2>

            <table
              style={{
                width: "100%",
                marginTop: "20px",
              }}
            >
              <thead>
                <tr>
                  <th>Category</th>
                  <th>Views</th>
                </tr>
              </thead>

              <tbody>
                {safeTrendingData.map((item, index) => (
                  <tr key={index}>
                    <td>{item.category}</td>
                    <td>{item.views}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div style={{ marginTop: "40px" }}>
            <h2>📈 Trending Categories Chart</h2>

            <ResponsiveContainer width="100%" height={350}>
              <BarChart data={trendingData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="category" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="views" fill="#3b82f6" />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div style={{ marginTop: "40px" }}>
            <h2>👥 Live Users Trend</h2>

            <ResponsiveContainer width="100%" height={350}>
              <LineChart data={liveUsersData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" />
                <YAxis />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="users"
                  stroke="#22c55e"
                  strokeWidth={3}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div style={{ marginTop: "40px" }}>
            <h2>📺 Active Streams Trend</h2>

            <ResponsiveContainer width="100%" height={350}>
              <LineChart data={streamTrendData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" />
                <YAxis />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="streams"
                  stroke="#3b82f6"
                  strokeWidth={3}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div style={{ marginTop: "40px" }}>
            <h2>🥧 Category Distribution</h2>

            <ResponsiveContainer width="100%" height={450}>
              <PieChart>
                <Pie
                  data={trendingData}
                  dataKey="views"
                  nameKey="category"
                  outerRadius={150}
                  label
                >
                  {safeTrendingData.map((entry, index) => (
                    <Cell
                      key={index}
                      fill={COLORS[index % COLORS.length]}
                    />
                  ))}
                </Pie>

                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    );
  }

  export default Dashboard;