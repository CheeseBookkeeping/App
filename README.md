# 🧀 起司记账 (CheeseBookkeeping)

面向大学生群体的轻量化、治愈系离线记账应用。

## ✨ 特性

- **纯本地离线** — 基于 SQLite 本地存储，无需网络即可使用
- **治愈系 UI** — 暖黄起司风格、大圆角、柔和配色，告别红色焦虑式提醒
- **深色/浅色模式** — 自动适配系统主题
- **收支管理** — 快速记账，分类清晰，支持备注
- **月度统计** — 收支总览、分类排行，消费一目了然
- **多平台支持** — 安卓真机、MuMu 模拟器均可运行

## 🛠 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 语言 | Dart |
| 本地存储 | SQLite (sqflite) |
| 状态管理 | StatefulWidget + ValueNotifier |
| 主题 | Material 3 (Material You) |

## 📁 目录结构

```
lib/
├── main.dart              # 程序入口、路由、底部导航
├── pages/                 # 业务页面
│   ├── home_page.dart     # 首页「明细」
│   ├── add_bill_page.dart # 记账页
│   ├── stats_page.dart    # 统计页
│   └── mine_page.dart     # 「我的」页面
├── widgets/               # 公共组件
│   └── bill_widgets.dart  # 账单卡片、统计卡片、分类网格
├── db/                    # SQLite 数据库
│   └── database_helper.dart
├── models/                # 数据模型
│   └── bill.dart
├── config/                # 全局配置
│   ├── app_theme.dart     # 主题配色
│   └── app_constants.dart # 常量、分类定义
└── utils/                 # 工具类
    └── formatter.dart     # 金额/日期格式化
```

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.11.3
- Android Studio / VS Code
- Android 真机 或 MuMu 模拟器

> **注意：** SQLite 依赖 `sqflite`，当前仅支持 Android / iOS / macOS。Windows、Chrome、Edge 等平台运行时会显示友好提示页。

### 运行

```bash
cd CheeseBookkeeping/App
flutter pub get
flutter run
```

## 📋 开发路线图

- [x] 首页：收支总览 + 近期记录
- [x] 记账页：收入/支出选择、分类、金额录入
- [x] 统计分析：分类排行、收支占比
- [ ] 多账本管理
- [ ] 预算管理
- [ ] 私密账户/隐藏账目
- [ ] 借入借出、人情往来
- [ ] 周期扣费、存钱目标
- [ ] 校园/社会模式主题切换
- [ ] 云端同步 (PostgreSQL)

## 📄 开源协议

本项目采用 [MIT License](LICENSE)。

---

Made with 🧀 for college students.
