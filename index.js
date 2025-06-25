const express = require("express");
const redis = require("redis");
const app = express();
const port = process.env.PORT || 3000;

const client = redis.createClient({
  url: `redis://${process.env.REDIS_HOST || "localhost"}:${process.env.REDIS_PORT || 6379}`,
});

client.on("error", (err) => console.error("Redis Client Error", err));

(async () => {
  await client.connect();
})();

app.get("/", async (req, res) => {
  const value = await client.get("demo_key");
  res.send(`✅ Redis says: ${value}`);
});

app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});

