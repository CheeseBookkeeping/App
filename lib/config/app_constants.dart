/// 全局常量 —— 分类列表、默认值等
///
/// 分类体系面向大学生场景：
/// - 支出覆盖日常消费、学习、社交等
/// - 收入覆盖兼职、生活费、奖学金等常见来源
/// 每个分类配有对应 emoji，用于 UI 展示
library;

class AppConstants {
  AppConstants._();

  // ── 支出分类 ──
  static const List<CategoryItem> expenseCategories = [
    CategoryItem('餐饮', '🍜'),
    CategoryItem('购物', '🛒'),
    CategoryItem('交通', '🚌'),
    CategoryItem('娱乐', '🎮'),
    CategoryItem('学习', '📚'),
    CategoryItem('社交', '🎉'),
    CategoryItem('数码', '💻'),
    CategoryItem('日用', '🧴'),
    CategoryItem('其他', '📌'),
  ];

  // ── 收入分类 ──
  static const List<CategoryItem> incomeCategories = [
    CategoryItem('兼职', '💼'),
    CategoryItem('生活费', '🏠'),
    CategoryItem('奖学金', '🏆'),
    CategoryItem('红包', '🧧'),
    CategoryItem('报销', '📋'),
    CategoryItem('其他', '📌'),
  ];

  /// 根据类型返回对应分类列表
  static List<CategoryItem> categoriesForType(String type) {
    return type == 'income' ? incomeCategories : expenseCategories;
  }
}

/// 分类项 —— 名称 + emoji
class CategoryItem {
  final String name;
  final String emoji;
  const CategoryItem(this.name, this.emoji);
}
