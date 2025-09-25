import express from "express";
const app = express();

app.get("/health", (_req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

app.get("/hello", (_req, res) => {
  res.json({ msg: "world" });
});

export default app;
