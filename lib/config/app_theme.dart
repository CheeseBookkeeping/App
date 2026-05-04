import 'package:flutter/material.dart';

/// 治愈系起司记账主题配置
///
/// 设计理念：
/// - 主色取自融化起司的暖黄色调，传递温暖、安全、无压力的感觉
/// - 拒绝刺眼的正红色，支出用柔和琥珀/橙红代替，收入用橄榄绿
/// - 大圆角（16–24dp）模拟起司圆润质感
/// - Material 3 色彩体系，自动适配深色 / 浅色模式

class AppTheme {
  AppTheme._();

  // ── 品牌色 ──
  static const Color cheeseYellow = Color(0xFFFFB347); // 起司暖黄
  static const Color cheeseLight = Color(0xFFFFF3DC); // 浅起司（浅色背景）
  static const Color cheeseDark = Color(0xFF2C2416); // 深色起司背景

  // ── 语义色（无红色焦虑） ──
  static const Color expenseColor = Color(0xFFE8895B); // 柔和琥珀-支出
  static const Color incomeColor = Color(0xFF6B9B6F); // 橄榄绿-收入
  static const Color balanceColor = Color(0xFF5B8BA0); // 雾蓝-结余

  // ── 圆角 ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;

  /// 浅色主题
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: cheeseYellow,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: cheeseYellow,
        onPrimary: const Color(0xFF5C3D1A),
        surface: cheeseLight,
        error: expenseColor, // 不刺眼的"错误色"
      ),
      scaffoldBackgroundColor: cheeseLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cheeseYellow,
        foregroundColor: const Color(0xFF5C3D1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }

  /// 深色主题
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: cheeseYellow,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: cheeseYellow,
        onPrimary: const Color(0xFF2C2416),
        surface: cheeseDark,
        error: expenseColor,
      ),
      scaffoldBackgroundColor: cheeseDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        color: const Color(0xFF3D3424),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cheeseYellow,
        foregroundColor: const Color(0xFF2C2416),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }
}
