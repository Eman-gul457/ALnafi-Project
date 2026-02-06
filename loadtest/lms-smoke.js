import http from "k6/http";
import { check, sleep } from "k6";

export let options = {
  stages: [
    { duration: "2m", target: 50 },
    { duration: "5m", target: 200 },
    { duration: "3m", target: 350 },
    { duration: "2m", target: 0 }
  ],
  thresholds: {
    http_req_duration: ["p(95)<1200"],
    http_req_failed: ["rate<0.03"]
  }
};

const BASE_URL = __ENV.BASE_URL || "https://lms.yourdomain.com";

export default function () {
  const res = http.get(`${BASE_URL}/`);
  check(res, {
    "status is 200 or 302": (r) => r.status === 200 || r.status === 302
  });
  sleep(1);
}
