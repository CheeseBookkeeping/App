import 'package:intl/intl.dart';

/// 通用格式化工具
///
/// - 金额格式化：固定 2 位小数，加 ¥ 前缀，支持负数
/// - 日期格式化：提供常用的展示格式

class Formatter {
  Formatter._();

  /// 金额格式化 → ¥1,234.56
  /// 保持 2 位小数，让数字对齐更好看
  static String amount(double value) {
    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';
    final formatted = NumberFormat('#,##0.00').format(absValue);
    return '$sign¥$formatted';
  }

  /// 简短日期 → 04/15
  static String shortDate(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }

  /// 完整日期 → 2025-04-15
  static String fullDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 月份标签 → 2025年4月
  static String monthLabel(DateTime date) {
    return DateFormat('yyyy年M月').format(date);
  }

  /// 星期几 → 周一、周二...
  static String weekday(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// 完整时间 → 04/15 14:30
  static String dateTime(DateTime date) {
    return DateFormat('MM/dd HH:mm').format(date);
  }

  /// 相对时间描述 → 今天 / 昨天 / 前天 / 日期
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    if (diff == 2) return '前天';
    return shortDate(date);
  }
}
