const express = require('express');
const cors = require('cors');
const mock = require('./mock');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 3000;
const CG = process.env.COINGECKO_URL || 'https://api.coingecko.com/api/v3';
const KEY = process.env.COINGECKO_API_KEY; // optional free "demo" key
const FORCE_MOCK = process.env.USE_MOCK === 'true';
const ALLOWED_DAYS = [1, 7, 30, 90, 365];

// ---- tiny in-memory cache (protects CoinGecko's free rate limit) ----------
const cache = new Map();
async function upstream(path, ttlMs) {
  const hit = cache.get(path);
  if (hit && Date.now() - hit.at < ttlMs) return hit.value;
  try {
    const headers = { accept: 'application/json' };
    if (KEY) headers['x-cg-demo-api-key'] = KEY;
    const res = await fetch(`${CG}${path}`, { headers });
    if (!res.ok) throw new Error(`CoinGecko responded ${res.status}`);
    const value = await res.json();
    cache.set(path, { at: Date.now(), value });
    return value;
  } catch (err) {
    if (hit) return hit.value; // serve stale data rather than failing
    throw err;
  }
}

// ---- respond with live data, fall back to mock ----------------------------
async function respond(res, live, fallback) {
  if (!FORCE_MOCK) {
    try {
      return res.json({ source: 'live', data: await live() });
    } catch (err) {
      console.warn('Live data failed, using mock:', err.message);
    }
  }
  res.json({ source: 'mock', data: fallback() });
}

app.get('/api/health', (_req, res) => res.json({ ok: true }));

app.get('/api/coins', (req, res) => {
  const perPage = Math.min(Number(req.query.per_page) || 100, 250);
  const page = Number(req.query.page) || 1;
  respond(
    res,
    () =>
      upstream(
        `/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=${perPage}&page=${page}&sparkline=true&price_change_percentage=1h,24h,7d,30d`,
        60_000
      ),
    () => mock.coins()
  );
});

app.get('/api/global', (_req, res) => {
  respond(res, async () => (await upstream('/global', 120_000)).data, () => mock.global());
});

app.get('/api/coins/:id/chart', (req, res) => {
  const days = Number(req.query.days) || 7;
  if (!ALLOWED_DAYS.includes(days)) return res.status(400).json({ error: 'days must be one of ' + ALLOWED_DAYS });
  const id = encodeURIComponent(req.params.id);
  respond(
    res,
    async () => (await upstream(`/coins/${id}/market_chart?vs_currency=usd&days=${days}`, 5 * 60_000)).prices,
    () => mock.chart(req.params.id, days)
  );
});

app.get('/api/coins/:id', (req, res) => {
  const id = encodeURIComponent(req.params.id);
  respond(
    res,
    async () => {
      const j = await upstream(
        `/coins/${id}?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false`,
        10 * 60_000
      );
      return {
        description: (j.description?.en || '').replace(/<[^>]*>/g, '').trim(),
        homepage: j.links?.homepage?.[0] || '',
      };
    },
    () => mock.about(req.params.id)
  );
});

app.listen(PORT, '0.0.0.0', () => console.log(`CoinScope API running on http://localhost:${PORT}`));
