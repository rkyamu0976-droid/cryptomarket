import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/coin.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: query);
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw ApiException('The server responded with an error (${res.statusCode}).');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The request took too long. Check your connection and try again.');
    } on SocketException {
      throw ApiException("Can't reach the server. Make sure the backend is running.");
    } on http.ClientException {
      throw ApiException("Can't reach the server. Make sure the backend is running.");
    } catch (_) {
      throw ApiException('Received an unexpected response from the server.');
    }
  }

  Future<({List<Coin> coins, bool isMock})> fetchCoins() async {
    final body = await _get('/api/coins', {'per_page': '100'});
    final coins = (body['data'] as List)
        .map((e) => Coin.fromJson(e as Map<String, dynamic>))
        .toList();
    return (coins: coins, isMock: body['source'] == 'mock');
  }

  Future<GlobalStats> fetchGlobal() async {
    final body = await _get('/api/global');
    return GlobalStats.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<ChartPoint>> fetchChart(String id, int days) async {
    final body = await _get('/api/coins/$id/chart', {'days': '$days'});
    return (body['data'] as List).map((e) {
      final p = e as List;
      return ChartPoint(
        DateTime.fromMillisecondsSinceEpoch((p[0] as num).toInt()),
        (p[1] as num).toDouble(),
      );
    }).toList();
  }

  Future<CoinAbout> fetchAbout(String id) async {
    final body = await _get('/api/coins/$id');
    final data = body['data'] as Map<String, dynamic>;
    return CoinAbout((data['description'] as String?) ?? '');
  }
}
