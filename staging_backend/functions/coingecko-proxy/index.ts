import {
  jsonResponse,
  optionsResponse,
} from "../_shared/staging.ts";

function oneYearPrices(): number[][] {
  const today = new Date();
  const prices: number[][] = [];
  for (let day = 364; day >= 0; day -= 1) {
    const date = new Date(today);
    date.setUTCDate(today.getUTCDate() - day);
    const wave = Math.sin(day / 28) * 1800;
    const trend = (364 - day) * 12;
    prices.push([date.getTime(), Math.round(65000 + trend + wave)]);
  }
  return prices;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return optionsResponse();
  }

  if (req.method !== "GET") {
    return jsonResponse(405, { ok: false, error: "Method not allowed" });
  }

  return jsonResponse(200, {
    prices: oneYearPrices(),
    bitcoin: { usd: 65000 },
    price: "65000.00",
    open: "64250.00",
    last: "65000.00",
    time: new Date().toISOString(),
    staging: true,
  });
});
