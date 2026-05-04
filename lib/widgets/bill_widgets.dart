import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../models/bill.dart';
import '../utils/formatter.dart';

/// 账单卡片 —— 用于首页列表
///
/// 左：分类 emoji + 分类名
/// 中：备注
/// 右：金额（支出暖橙 / 收入橄榄绿）+ 日期
class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = bill.type == 'expense';
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final sign = isExpense ? '-' : '+';

    // 查找对应分类的 emoji
    final categories = AppConstants.categoriesForType(bill.type);
    final cat = categories.firstWhere(
      (c) => c.name == bill.category,
      orElse: () => const CategoryItem('其他', '📌'),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── 左侧：分类图标 ──
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Center(
                  child: Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),

              // ── 中间：分类 + 备注 ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (bill.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        bill.note,
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // ── 右侧：金额 + 日期 ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${Formatter.amount(bill.amount)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatter.relativeDate(bill.date),
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 收支统计卡片 —— 顶部三栏概要
class StatsCard extends StatelessWidget {
  final double income;
  final double expense;
  final String monthLabel;

  const StatsCard({
    super.key,
    required this.income,
    required this.expense,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            // 月份标签
            Text(
              monthLabel,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            // 三栏数据
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: '收入',
                  amount: Formatter.amount(income),
                  color: AppTheme.incomeColor,
                ),
                _StatItem(
                  label: '支出',
                  amount: Formatter.amount(expense),
                  color: AppTheme.expenseColor,
                ),
                _StatItem(
                  label: '结余',
                  amount: Formatter.amount(balance),
                  color: AppTheme.balanceColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
            )),
        const SizedBox(height: 6),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 空状态占位 —— 无账单时的引导提示
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    this.message = '还没有账单记录\n点击 + 开始记账吧',
    this.icon = Icons.receipt_long_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 72,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类选择网格 —— 用于记账页
class CategoryGrid extends StatelessWidget {
  final String billType; // 'income' | 'expense'
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryGrid({
    super.key,
    required this.billType,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final categories = AppConstants.categoriesForType(billType);
    final primary = billType == 'expense'
        ? AppTheme.expenseColor
        : AppTheme.incomeColor;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final selected = cat.name == selectedCategory;
        return GestureDetector(
          onTap: () => onSelect(cat.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.15)
                  : Theme.of(context)
                      .cardColor
                      .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: selected ? primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              '${cat.emoji}  ${cat.name}',
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? primary : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
