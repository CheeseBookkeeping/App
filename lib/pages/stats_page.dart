import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../db/database_helper.dart';
import '../utils/formatter.dart';

/// 统计页 —— 当月分类支出排行 + 收入/支出占比
///
/// 设计要点：
/// - 从 SQLite 读出当月各分类汇总，用进度条展示相对占比
/// - 顶部复用 StatsCard 同一数据源

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final DatabaseHelper _db = DatabaseHelper();

  double _income = 0;
  double _expense = 0;
  List<Map<String, dynamic>> _categoryStats = [];
  bool _loading = true;
  String? _error;

  String get _monthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final summary = await _db.getMonthSummary(_monthKey);
      final stats = await _db.getCategoryStats(_monthKey);
      if (mounted) {
        setState(() {
          _income = summary['income'] ?? 0;
          _expense = summary['expense'] ?? 0;
          _categoryStats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final maxAmount = _categoryStats.isNotEmpty
        ? (_categoryStats.first['total'] as num).toDouble()
        : 1.0;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 收支概览
          _SummaryRow(income: _income, expense: _expense),
          const SizedBox(height: 24),

          // 支出分类排行
          if (_categoryStats.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Text('本月暂无支出数据', style: TextStyle(color: Colors.grey)),
              ),
            )
          else ...[
            const Text('支出分类排行',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ..._categoryStats.map((row) {
              final category = row['category'] as String;
              final total = (row['total'] as num).toDouble();
              final count = row['count'] as int;
              final ratio = maxAmount > 0 ? total / maxAmount : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$category  ·  $count笔',
                            style: const TextStyle(fontSize: 14)),
                        Text(Formatter.amount(total),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.expenseColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor:
                            AppTheme.expenseColor.withValues(alpha: 0.12),
                        color: AppTheme.expenseColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double income;
  final double expense;
  const _SummaryRow({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SummaryItem(
                label: '收入', amount: Formatter.amount(income), color: AppTheme.incomeColor),
            _SummaryItem(
                label: '支出', amount: Formatter.amount(expense), color: AppTheme.expenseColor),
            _SummaryItem(
                label: '结余', amount: Formatter.amount(balance), color: AppTheme.balanceColor),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  const _SummaryItem(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7))),
        const SizedBox(height: 6),
        Text(amount,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
