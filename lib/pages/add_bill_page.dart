import 'package:flutter/material.dart';
import 'dart:math';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../db/database_helper.dart';
import '../models/bill.dart';
import '../widgets/bill_widgets.dart';

/// 记账页 —— 选类型 → 选分类 → 填金额 → 填备注 → 底部保存
///
/// 优化点：
/// - 金额使用系统键盘录入（TextInputType.numberWithOptions），不再自定义键盘
/// - 保存按钮固定在底部，单手操作无障碍
/// - 编辑模式下预填已有数据

class AddBillPage extends StatefulWidget {
  final Bill? editBill;

  const AddBillPage({super.key, this.editBill});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  bool get _isEdit => widget.editBill != null;

  String _type = 'expense';
  String _category = '餐饮';
  bool _saving = false;

  // ── 生命周期 ──

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final b = widget.editBill!;
      _type = b.type;
      _category = b.category;
      _amountController.text = b.amount.toStringAsFixed(2);
      _noteController.text = b.note;
    }
    // 自动弹出键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEdit) _amountFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  // ── 保存 ──

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    final parsed = double.tryParse(amountText);
    if (parsed == null || parsed <= 0) {
      _showSnack('请输入有效金额（大于 0）');
      return;
    }

    setState(() => _saving = true);

    try {
      if (_isEdit) {
        final updated = Bill(
          id: widget.editBill!.id,
          type: _type,
          amount: parsed,
          category: _category,
          note: _noteController.text.trim(),
          date: widget.editBill!.date,
        );
        await _db.updateBill(updated);
      } else {
        final bill = Bill(
          id:
              '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
          type: _type,
          amount: parsed,
          category: _category,
          note: _noteController.text.trim(),
          date: DateTime.now(),
        );
        await _db.insertBill(bill);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('保存失败: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── UI ──

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == 'expense';
    final accent = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑账单' : '记一笔')),
      body: Column(
        children: [
          // 上半部分可滚动
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 收支类型切换 ──
                  _TypeSwitcher(
                    selectedType: _type,
                    onChanged: (t) => setState(() {
                      _type = t;
                      _category =
                          AppConstants.categoriesForType(t).first.name;
                    }),
                  ),
                  const SizedBox(height: 24),

                  // ── 金额输入（系统键盘） ──
                  TextField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: accent,
                        letterSpacing: 2),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(fontSize: 32, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── 分类 ──
                  Text('选择分类',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7))),
                  const SizedBox(height: 10),
                  CategoryGrid(
                    billType: _type,
                    selectedCategory: _category,
                    onSelect: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: 28),

                  // ── 备注 ──
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: '备注（可选）',
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLength: 60,
                  ),
                ],
              ),
            ),
          ),

          // ── 底部保存按钮 ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('保存', style: TextStyle(fontSize: 17)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────
//  类型切换组件（与上版相同）
// ──────────────────────────────────

class _TypeSwitcher extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _TypeSwitcher({required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: '支出',
            emoji: '💸',
            active: selectedType == 'expense',
            color: AppTheme.expenseColor,
            onTap: () => onChanged('expense'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            label: '收入',
            emoji: '💰',
            active: selectedType == 'income',
            color: AppTheme.incomeColor,
            onTap: () => onChanged('income'),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.emoji,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: active ? color : Theme.of(context).dividerColor,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    color: active ? color : null,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
