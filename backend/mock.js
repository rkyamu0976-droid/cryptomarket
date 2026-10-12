// Sample data used when CoinGecko is unreachable or rate-limited.
// id, symbol, name, price, circulating, max supply, volatility
const BASE = [
  ['bitcoin', 'btc', 'Bitcoin', 67250, 19.7e6, 21e6, 0.012],
  ['ethereum', 'eth', 'Ethereum', 3480, 120.4e6, null, 0.015],
  ['tether', 'usdt', 'Tether', 1.0, 110e9, null, 0.0004],
  ['binancecoin', 'bnb', 'BNB', 590, 145.9e6, null, 0.013],
  ['solana', 'sol', 'Solana', 172, 460e6, null, 0.022],
  ['ripple', 'xrp', 'XRP', 0.52, 56e9, 100e9, 0.018],
  ['usd-coin', 'usdc', 'USDC', 1.0, 34e9, null, 0.0004],
  ['cardano', 'ada', 'Cardano', 0.45, 35.6e9, 45e9, 0.02],
  ['dogecoin', 'doge', 'Dogecoin', 0.16, 145e9, null, 0.028],
  ['avalanche-2', 'avax', 'Avalanche', 36, 392e6, 720e6, 0.024],
  ['chainlink', 'link', 'Chainlink', 14.2, 587e6, 1e9, 0.022],
  ['polkadot', 'dot', 'Polkadot', 6.8, 1.4e9, null, 0.021],
  ['litecoin', 'ltc', 'Litecoin', 82, 74.7e6, 84e6, 0.017],
  ['tron', 'trx', 'TRON', 0.12, 87e9, null, 0.014],
  ['stellar', 'xlm', 'Stellar', 0.11, 29e9, 50e9, 0.019],
  ['shiba-inu', 'shib', 'Shiba Inu', 0.0000185, 589e12, null, 0.03],
];

function hash(str) {
  let h = 7;
  for (const c of str) h = (h * 31 + c.charCodeAt(0)) % 2147483647;
  return h || 1;
}
function rng(seed) {
  let s = seed;
  return () => (s = (s * 16807) % 2147483647) / 2147483647;
}
function walk(id, steps, price, vol) {
  const r = rng(hash(id));
  const raw = [1];
  for (let i = 1; i < steps; i++) raw.push(raw[i - 1] * (1 + (r() - 0.5) * vol * 2));
  const k = price / raw[raw.length - 1];
  return raw.map((v) => v * k);
}
const pct = (a, b) => (b === 0 ? 0 : ((a - b) / b) * 100);

function coins() {
  return BASE.map(([id, symbol, name, price, circ, max, vol], i) => {
    const spark = walk(id, 168, price, vol);
    const last = spark[spark.length - 1];
    const day = spark.slice(-24);
    const r = rng(hash(id + 'x'));
    return {
      id, symbol, name, image: '',
      current_price: last,
      market_cap: last * circ,
      market_cap_rank: i + 1,
      total_volume: last * circ * (0.015 + r() * 0.05),
      high_24h: Math.max(...day),
      low_24h: Math.min(...day),
      price_change_percentage_24h: pct(last, spark[spark.length - 25]),
      price_change_percentage_1h_in_currency: pct(last, spark[spark.length - 2]),
      price_change_percentage_7d_in_currency: pct(last, spark[0]),
      price_change_percentage_30d_in_currency: (r() - 0.45) * 30,
      circulating_supply: circ,
      total_supply: max || circ * 1.02,
      max_supply: max,
      ath: Math.max(...spark) * (1.1 + r() * 0.4),
      sparkline_in_7d: { price: spark },
    };
  });
}

function global() {
  const list = coins();
  const cap = list.reduce((s, c) => s + c.market_cap, 0);
  const vol = list.reduce((s, c) => s + c.total_volume, 0);
  const share = (id) => (list.find((c) => c.id === id).market_cap / cap) * 100;
  return {
    active_cryptocurrencies: 14250,
    total_market_cap: { usd: cap },
    total_volume: { usd: vol },
    market_cap_percentage: { btc: share('bitcoin'), eth: share('ethereum') },
    market_cap_change_percentage_24h_usd: 1.42,
  };
}

function chart(id, days) {
  const base = BASE.find((b) => b[0] === id) || BASE[0];
  const steps = days === 1 ? 96 : days === 7 ? 168 : 120;
  const prices = walk(id + days, steps, base[3], base[6] * (days > 30 ? 2.5 : 1));
  const end = Date.now();
  const gap = (days * 86400000) / steps;
  return prices.map((p, i) => [Math.round(end - (steps - 1 - i) * gap), p]);
}

function about(id) {
  const c = BASE.find((b) => b[0] === id);
  return {
    description: c
      ? `${c[2]} (${c[1].toUpperCase()}) is shown with sample data because the live data provider is unavailable right now. Connect the backend to the internet to see the real description.`
      : '',
    homepage: '',
  };
}

module.exports = { coins, global, chart, about };
