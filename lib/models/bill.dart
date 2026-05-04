/// 账单数据模型 — 映射 SQLite bills 表
///
/// 设计要点：
/// - id 使用 DateTime 毫秒时间戳 + 随机数，保证离线环境下的唯一性
/// - toMap / fromMap 负责与 SQLite 行数据互转，避免手写 SQL 拼接
/// - date 字段以文本存储 (ISO 8601)，保证可读性，查询时用字符串比较即可按日筛选
class Bill {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  Bill({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  /// 转为 SQLite 行 —— 注意 date 写为 ISO 8601 字符串
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  /// 从 SQLite 行重建对象
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      note: map['note'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
    );
  }

  /// 方便调试的序列化
  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() =>
      'Bill(id: $id, type: $type, amount: $amount, category: $category)';
}
