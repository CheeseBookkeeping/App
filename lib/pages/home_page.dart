import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../db/database_helper.dart';
import '../models/bill.dart';
import '../utils/formatter.dart';
import '../widgets/bill_widgets.dart';

/// 首页「明细」—— 收支总览 + 当月统计 + 按日分组账单列表
///
/// 注意：FAB 和底部栏由父级 MainShell 统一管理，本页不再自行持有。

class HomePage extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const HomePage({super.key, this.refreshNotifier});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final DatabaseHelper _db = DatabaseHelper();

  double _monthIncome = 0;
  double _monthExpense = 0;
  List<Bill> _bills = [];
  bool _loading = true;
  String? _error;

  String get _monthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.refreshNotifier?.addListener(_loadData);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshNotifier != oldWidget.refreshNotifier) {
      oldWidget.refreshNotifier?.removeListener(_loadData);
      widget.refreshNotifier?.addListener(_loadData);
    }
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final summary = await _db.getMonthSummary(_monthKey);
      final bills = await _db.getBillsByMonth(_monthKey);
      if (mounted) {
        setState(() {
          _monthIncome = summary['income'] ?? 0;
          _monthExpense = summary['expense'] ?? 0;
          _bills = bills;
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

  List<_DayGroup> _groupByDate() {
    final map = <String, List<Bill>>{};
    for (final bill in _bills) {
      final key = Formatter.fullDate(bill.date);
      map.putIfAbsent(key, () => []).add(bill);
    }
    return map.entries.map((e) {
      final date = DateTime.parse(e.key);
      return _DayGroup(date: date, bills: e.value);
    }).toList();
  }

  Future<void> _confirmDelete(Bill bill) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除账单'),
        content: Text('确定要删除这笔 ${bill.category} 的账单吗？\n${Formatter.amount(bill.amount)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('删除', style: TextStyle(color: AppTheme.expenseColor))),
        ],
      ),
    );

    if (ok == true) {
      await _db.deleteBill(bill.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = Formatter.monthLabel(DateTime.now());

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

    if (_bills.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            StatsCard(
                income: _monthIncome,
                expense: _monthExpense,
                monthLabel: monthLabel),
            const SizedBox(height: 80),
            const EmptyState(),
          ],
        ),
      );
    }

    final groups = _groupByDate();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return StatsCard(
                income: _monthIncome,
                expense: _monthExpense,
                monthLabel: monthLabel);
          }
          final group = groups[index - 1];
          return _DaySection(group: group, onDelete: _confirmDelete);
        },
      ),
    );
  }
}

/// 按天分组
class _DaySection extends StatelessWidget {
  final _DayGroup group;
  final Future<void> Function(Bill) onDelete;

  const _DaySection({required this.group, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final totalExpense = group.bills
        .where((b) => b.type == 'expense')
        .fold<double>(0, (sum, b) => sum + b.amount);
    final totalIncome = group.bills
        .where((b) => b.type == 'income')
        .fold<double>(0, (sum, b) => sum + b.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            children: [
              Text(Formatter.relativeDate(group.date),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 8),
              Text(Formatter.weekday(group.date),
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7))),
              const Spacer(),
              if (totalExpense > 0)
                Text('支出 ${Formatter.amount(totalExpense)}',
                    style: TextStyle(fontSize: 12, color: AppTheme.expenseColor)),
              if (totalIncome > 0) ...[
                if (totalExpense > 0) const SizedBox(width: 8),
                Text('收入 ${Formatter.amount(totalIncome)}',
                    style: TextStyle(fontSize: 12, color: AppTheme.incomeColor)),
              ],
            ],
          ),
        ),
        ...group.bills.map(
          (bill) => BillCard(bill: bill, onLongPress: () => onDelete(bill)),
        ),
      ],
    );
  }
}

class _DayGroup {
  final DateTime date;
  final List<Bill> bills;
  const _DayGroup({required this.date, required this.bills});
}
