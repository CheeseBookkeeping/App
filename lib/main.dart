import 'dart:io';
import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'db/database_helper.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/mine_page.dart';
import 'pages/add_bill_page.dart';

/// 起司记账 CheeseBookkeeping —— 程序入口

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CheeseBookApp());
}

class CheeseBookApp extends StatelessWidget {
  const CheeseBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '起司记账',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

/// 主框架 —— 底部导航 + 三页切换 + FAB
///
/// 如果当前平台不支持 SQLite（Windows / Chrome / Edge），
/// 显示友好提示页，解决之前"一直转圈"的问题。

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // 用于通知首页刷新的计数器：每次记一笔保存成功后 +1
  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);

  static const _titles = ['起司记账', '统计分析', '我的'];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddBillPage()),
    );
    if (result == true && mounted) {
      _refreshNotifier.value++;
    }
  }

  @override
  void dispose() {
    _refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── 平台不支持时展示兜底页 ──
    if (!DatabaseHelper.isSupported) {
      return Scaffold(
        appBar: AppBar(title: const Text('🧀 起司记账')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_android,
                    size: 72, color: AppTheme.cheeseYellow),
                const SizedBox(height: 20),
                const Text('抱歉，当前平台不支持',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  '起司记账基于 SQLite 本地存储，\n请在 MuMu 模拟器 或 安卓真机 上运行。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Text(
                  '当前平台：${Platform.operatingSystem}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── 正常模式 ──
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(refreshNotifier: _refreshNotifier),
          const StatsPage(),
          const MinePage(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('记一笔'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '明细',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
