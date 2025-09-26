class Trade {
  final String politician;
  final String ticker;
  final DateTime date;
  final String type; // "Purchase" / "Sale"
  final String amountRange; // e.g. "$1,001 - $15,000"
  final double? estimatedAmount; // optional numeric estimate
  final String? sourceId; // id from API

  Trade({
    required this.politician,
    required this.ticker,
    required this.date,
    required this.type,
    required this.amountRange,
    this.estimatedAmount,
    this.sourceId,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    // 兼容不同API的常见字段名
    String politician = (json['politician'] ?? json['representative'] ?? json['name'] ?? '') as String;
    String ticker = (json['ticker'] ?? json['symbol'] ?? json['asset'] ?? '') as String;
    String type = (json['transaction_type'] ?? json['type'] ?? json['action'] ?? 'Unknown') as String;
    String amountRange = (json['amount'] ?? json['amount_range'] ?? json['value'] ?? '') as String;
    String id = (json['id'] ?? json['trade_id'] ?? '') as String;

    DateTime date;
    if (json['transaction_date'] != null) {
      date = DateTime.parse(json['transaction_date']);
    } else if (json['reported_date'] != null) {
      date = DateTime.parse(json['reported_date']);
    } else {
      date = DateTime.now();
    }

    double? estimated;
    if (json['estimated_amount'] != null) {
      estimated = (json['estimated_amount'] as num).toDouble();
    } else {
      estimated = null;
    }

    return Trade(
      politician: politician,
      ticker: ticker,
      date: date,
      type: type,
      amountRange: amountRange,
      estimatedAmount: estimated,
      sourceId: id.isEmpty ? null : id,
    );
  }
}
