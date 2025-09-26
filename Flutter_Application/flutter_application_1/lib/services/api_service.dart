import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trade.dart';

class ApiService {
  // 示例：Quiver Quantitative 风格（请注册并替换为你的 key 与 endpoint）
  static const String baseUrl = 'https://api.quiverquant.com/beta'; // 假定端点
  static const String apiKey = 'YOUR_API_KEY';

  // 获取最近 trades（分页）
  static Future<List<Trade>> fetchRecentTrades({int page = 0, int limit = 50}) async {
    final uri = Uri.parse('$baseUrl/congresstrading/stock/ALL?limit=$limit&page=$page');
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'X-API-KEY': apiKey, // 某些服务用 Authorization: Bearer ...
    });

    if (res.statusCode != 200) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }

    final data = json.decode(res.body);
    // data 可能是 list 或 {results: [...]}
    final List<dynamic> items = data is List ? data : (data['results'] ?? data['data'] ?? []);
    return items.map((it) {
      try {
        return Trade.fromJson(it as Map<String, dynamic>);
      } catch (e) {
        // 忽略解析失败的项
        return null;
      }
    }).whereType<Trade>().toList();
  }

  // 获取单个议员的所有交易（按时间排序）
  static Future<List<Trade>> fetchTradesByPolitician(String politicianName) async {
    final q = Uri.encodeComponent(politicianName);
    final uri = Uri.parse('$baseUrl/congresstrading/politician/$q');
    final res = await http.get(uri, headers: {'X-API-KEY': apiKey, 'Accept': 'application/json'});

    if (res.statusCode != 200) throw Exception('API err ${res.statusCode}');
    final data = json.decode(res.body);
    final List<dynamic> items = data is List ? data : (data['trades'] ?? data['results'] ?? []);
    return items.map((it) => Trade.fromJson(it as Map<String, dynamic>)).toList();
  }
}
