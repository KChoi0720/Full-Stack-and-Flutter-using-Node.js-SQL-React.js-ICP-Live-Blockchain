import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/trade.dart';

class DetailPage extends StatefulWidget {
  final String politicianName;
  DetailPage({required this.politicianName});
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Trade> trades = [];
  bool loading = true;
  String groupBy = 'month'; // 'month' or 'year'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; });
    try {
      trades = await ApiService.fetchTradesByPolitician(widget.politicianName);
    } catch (e) {
      // error
    }
    setState(() { loading = false; });
  }

  // 简单按月/年聚合：统计每个月的交易笔数（可改为金额）
  Map<String, int> aggregateTrades() {
    final Map<String, int> map = {};
    for (final t in trades) {
      final key = groupBy == 'month'
          ? '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}'
          : '${t.date.year}';
      map[key] = (map[key] ?? 0) + 1;
    }
    // 保证按时间排序
    final sortedKeys = map.keys.toList()..sort();
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, map[k]!)));
  }

  @override
  Widget build(BuildContext context) {
    final agg = aggregateTrades();
    final labels = agg.keys.toList();
    final values = agg.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.politicianName)),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Group:'),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: groupBy,
                      items: ['month', 'year'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) { setState(() { groupBy = v!; }); },
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: values.isEmpty
                        ? Center(child: Text('No trades data'))
                        : LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (i, meta) {
                                  final index = i.toInt();
                                  if (index < 0 || index >= labels.length) return Text('');
                                  final txt = labels[index];
                                  return Text(txt, style: TextStyle(fontSize: 10));
                                }, reservedSize: 36)),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i].toDouble())),
                                  isCurved: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(show: true),
                                )
                              ],
                              minY: 0,
                              maxY: (values.reduce((a,b)=> a>b?a:b)).toDouble() + 1,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: trades.map((t) => ListTile(
                      title: Text('${t.ticker} • ${t.type}'),
                      subtitle: Text('${t.date.toLocal().toIso8601String().split("T")[0]} • ${t.amountRange}'),
                    )).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
