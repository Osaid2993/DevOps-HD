import request from "supertest";
import app from "./app.js";

describe("api", () => {
  it("health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
  });

  it("hello returns world", async () => {
    const res = await request(app).get("/hello");
    expect(res.status).toBe(200);
    expect(res.body.msg).toBe("world");
  });
});
