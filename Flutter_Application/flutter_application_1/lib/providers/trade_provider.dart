import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/trade.dart';
import '../services/api_service.dart';

class TradeProvider with ChangeNotifier {
  List<Trade> trades = [];
  bool loading = false;
  String? error;
  Timer? _pollTimer;
  int _page = 0;

  Future<void> loadInitial() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      trades = await ApiService.fetchRecentTrades(page: 0, limit: 50);
      _page = 0;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    _page += 1;
    try {
      final more = await ApiService.fetchRecentTrades(page: _page, limit: 50);
      trades.addAll(more);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // 启动轮询（准实时）
  void startPolling({Duration interval = const Duration(seconds: 60)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) async {
      try {
        final latest = await ApiService.fetchRecentTrades(page: 0, limit: 50);
        // 简单合并：用最新列表替代（也可以做差异合并）
        trades = latest;
        notifyListeners();
      } catch (_) { /* 忽略轮询错误 */ }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
