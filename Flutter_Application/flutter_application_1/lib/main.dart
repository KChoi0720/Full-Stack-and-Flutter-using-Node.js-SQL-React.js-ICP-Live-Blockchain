import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

// ✅ 假数据：多位议员，每位12条交易记录
final List<Map<String, dynamic>> members = [
  {
    "name": "Nancy Pelosi",
    "avatar": Icons.account_circle,
    "trades": List.generate(12, (i) {
      final buy = 100 + i * 5;
      final sell = buy + (i % 2 == 0 ? 10 : -5);
      return {
        "buyDate": "2025-${(i + 1).toString().padLeft(2, '0')}-01",
        "sellDate": "2025-${(i + 1).toString().padLeft(2, '0')}-10",
        "buyPrice": buy,
        "sellPrice": sell,
        "change": sell >= buy ? "up" : "down"
      };
    })
  },
  {
    "name": "Dan Crenshaw",
    "avatar": Icons.person,
    "trades": List.generate(12, (i) {
      final buy = 50 + i * 3;
      final sell = buy + (i % 3 == 0 ? 5 : -2);
      return {
        "buyDate": "2025-${(i + 1).toString().padLeft(2, '0')}-02",
        "sellDate": "2025-${(i + 1).toString().padLeft(2, '0')}-12",
        "buyPrice": buy,
        "sellPrice": sell,
        "change": sell >= buy ? "up" : "down"
      };
    })
  },
  {
    "name": "Elizabeth Warren",
    "avatar": Icons.face,
    "trades": List.generate(12, (i) {
      final buy = 80 + i * 4;
      final sell = buy + (i % 2 == 0 ? 8 : -3);
      return {
        "buyDate": "2025-${(i + 1).toString().padLeft(2, '0')}-03",
        "sellDate": "2025-${(i + 1).toString().padLeft(2, '0')}-13",
        "buyPrice": buy,
        "sellPrice": sell,
        "change": sell >= buy ? "up" : "down"
      };
    })
  },
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Congress Stock Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
    );
  }
}

// ✅ 顶部导航栏 + 页面切换
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 1; // 默认 Congress Members

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (selectedIndex) {
      case 0:
        body = const Center(child: Text("Home Page"));
        break;
      case 1:
        body = CongressMembersPage();
        break;
      case 2:
        body = const Center(child: Text("Contact Us Page"));
        break;
      default:
        body = CongressMembersPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.show_chart, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  navItem("Home", 0),
                  const SizedBox(width: 16),
                  navItem("Congress Members", 1),
                  const SizedBox(width: 16),
                  navItem("Contact Us", 2),
                ],
              ),
            ),
          ],
        ),
      ),
      body: body,
    );
  }

  Widget navItem(String label, int index) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 16)),
    );
  }
}

// ✅ Congress Members 列表页
class CongressMembersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          color: Colors.grey[100],
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Text("${index + 1}"),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> member = members[index];
              final String name = member["name"] as String;
              final IconData avatar = member["avatar"] as IconData;
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MemberDetailPage(member: member)));
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(avatar)),
                    title: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ✅ 详情页：左右布局，左表格，右趋势图
class MemberDetailPage extends StatelessWidget {
  final Map<String, dynamic> member;
  const MemberDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> trades =
        (member["trades"] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    final List<FlSpot> spots = trades
        .asMap()
        .entries
        .map((e) => FlSpot(
            e.key.toDouble(), (e.value["sellPrice"] as int).toDouble()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(member["name"] as String)),
      body: Row(
        children: [
          // 左侧表格
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text("Buy Date")),
                  DataColumn(label: Text("Sell Date")),
                  DataColumn(label: Text("Buy Price")),
                  DataColumn(label: Text("Sell Price")),
                  DataColumn(label: Text("Trend")),
                ],
                rows: trades.map((trade) {
                  final bool isUp = trade["change"] == "up";
                  return DataRow(cells: [
                    DataCell(Text(trade["buyDate"] as String)),
                    DataCell(Text(trade["sellDate"] as String)),
                    DataCell(Text("\$${trade["buyPrice"]}")),
                    DataCell(Text("\$${trade["sellPrice"]}")),
                    DataCell(Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isUp ? Colors.green : Colors.red)),
                  ]);
                }).toList(),
              ),
            ),
          ),
          // 右侧趋势图
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: FlDotData(show: true),
                    belowBarData:
                        BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
