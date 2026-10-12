import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/market_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const CoinScopeApp());
}

class CoinScopeApp extends StatelessWidget {
  const CoinScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<MarketProvider>(
            create: (c) => MarketProvider(c.read<ApiService>())),
        ChangeNotifierProvider<WatchlistProvider>(create: (_) => WatchlistProvider()),
      ],
      child: MaterialApp(
        title: 'CoinScope',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const MainShell(),
      ),
    );
  }
}
