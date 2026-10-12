# CoinScope – mini CoinGecko-style crypto research app

Flutter app + small Node.js backend (proxy to CoinGecko with caching and an automatic mock-data fallback).

## 1. Start the backend
```bash
cd backend
npm install
npm start            # http://localhost:3000
# optional: USE_MOCK=true npm start   (always use sample data)
# optional: COINGECKO_API_KEY=xxxx npm start   (free demo key)
```
Quick check: open http://localhost:3000/api/coins in a browser.

## 2. Create the Flutter project and drop in the code
```bash
flutter create coinscope
cd coinscope
flutter pub add http provider fl_chart shared_preferences google_fonts intl
```
Then copy this folder's `lib/` over the generated `lib/` (replace everything).

### Android: allow the app to talk to your local HTTP backend
In `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" ... >
```
(the INTERNET permission goes just above `<application>`).

## 3. Run
```bash
# Android emulator (default URL http://10.0.2.2:3000)
flutter run

# Real phone on the same Wi-Fi: use your PC's LAN IP
flutter run --dart-define=API_BASE=http://192.168.1.5:3000
```
iOS simulator: `--dart-define=API_BASE=http://localhost:3000`

## Requirement checklist
- Coin list, coin details, market statistics, watchlist screens
- REST API data: price, volume, market cap, supply (live via backend, mock fallback)
- Search, filter (all / gainers / losers), sort (rank, price, 24h change, volume, market cap)
- Watchlist saved on device (shared_preferences), swipe-to-remove with undo
- Interactive price chart (touch tooltip, 24H / 7D / 30D / 90D / 1Y)
- Loading skeletons, error with retry, empty states, pull-to-refresh, 60s auto-refresh
- Backend: Node.js + Express
