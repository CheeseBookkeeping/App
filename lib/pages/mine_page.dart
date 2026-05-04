import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../db/database_helper.dart';
import '../utils/formatter.dart';

/// 「我的」页面 —— 数据概览、导出提示、预留云端同步入口
///
/// 设计要点：
/// - 展示总账单数、本月记录数，体感可控
/// - 提供月份切换入口（后续迭代）
/// - 预留云端同步按钮，目前显示"即将上线"

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final DatabaseHelper _db = DatabaseHelper();

  int _totalCount = 0;
  int _monthCount = 0;
  bool _loading = true;
  String? _error;

  String get _monthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final total = await _db.getBillCount();
      final monthBills = await _db.getBillsByMonth(_monthKey);
      if (mounted) {
        setState(() {
          _totalCount = total;
          _monthCount = monthBills.length;
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
    return RefreshIndicator(
      onRefresh: _loadInfo,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 数据概览卡片
          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ))
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              ),
            )
          else ...[
            _InfoCard(
              title: '📦 数据概览',
              children: [
                _InfoRow(label: '全部账单', value: '$_totalCount 笔'),
                const Divider(),
                _InfoRow(
                    label: Formatter.monthLabel(DateTime.now()),
                    value: '$_monthCount 笔'),
              ],
            ),
            const SizedBox(height: 16),

            // 功能列表
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('切换月份'),
                    subtitle: const Text('查看历史账单'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('月份切换功能即将上线')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('数据备份'),
                    subtitle: const Text('本地备份与恢复'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('备份功能即将上线')),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.cloud_outlined),
                    title: const Text('云端同步'),
                    subtitle: const Text('PostgreSQL 同步（即将上线）'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('云端同步功能即将上线')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.cheeseYellow)),
        ],
      ),
    );
  }
}
