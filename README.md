# EcoVerse - 灵境

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.16+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.0+-purple.svg" alt="Dart Version">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20iOS%20%7C%20Android-green.svg" alt="Platforms">
</p>

<div align="center">
  <h1>🌍 灵境 EcoVerse</h1>
  <p>基于 Flutter 的开放创造式沙盒游戏</p>
</div>

## 功能特性

- 🎮 **程序化生成世界** - 无限地形，使用 Perlin Noise 算法
- 🏗️ **建造系统** - 放置和破坏方块，创建你的梦想世界
- 👾 **生物系统** - 被动和敌对生物，AI 行为
- 💾 **存档系统** - 世界数据持久化保存
- 🌙 **昼夜循环** - 动态光照和天空变化
- 🎯 **双模式** - 生存模式和创造模式
- 📱 **跨平台** - Windows, macOS, iOS, Android 支持

## 快速开始

### 环境要求

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode / Visual Studio

### 运行游戏

```bash
# Clone the repository
git clone https://github.com/11lzq11/ecoverse.git
cd ecoverse

# Get dependencies
flutter pub get

# Run on your device
flutter run

# Or build for specific platform
flutter build windows --release
flutter build macos --release
flutter build ios --release
flutter build apk --release
```

## 构建 (GitHub Actions)

本项目配置了自动化的 CI/CD 流程。推送代码到 main/master 分支后，GitHub Actions 会自动构建所有平台的版本：

- **Windows**: 生成 `.exe` 安装包
- **macOS**: 生成 `.dmg` 安装包
- **iOS**: 生成未签名的 `.ipa` 文件
- **Android**: 生成 `.apk` 文件

构建产物会在 workflow 完成后作为 artifacts 提供下载。

### 手动触发

1. 进入 Actions 标签页
2. 选择 "Build EcoVerse" workflow
3. 点击 "Run workflow"
4. 等待构建完成

## 操作说明

### 移动控制

| 按键 | 操作 |
|------|------|
| W / ↑ | 前进 |
| S / ↓ | 后退 |
| A / ← | 左移 |
| D / → | 右移 |
| 空格 | 跳跃 |
| Shift | 冲刺 |
| F | 飞行（创造模式）|

### 交互操作

| 操作 | 功能 |
|------|------|
| 鼠标左键 | 破坏方块 |
| 鼠标右键 | 放置方块 |
| E | 打开背包 |
| 数字键 1-9 | 切换快捷栏 |
| C | 切换创造/生存模式 |

### 快捷键

| 按键 | 操作 |
|------|------|
| ESC | 暂停菜单 |

## 项目结构

```
ecoverse/
├── lib/
│   └── src/
│       ├── game/
│       │   ├── ecoverse_game.dart      # 主游戏类
│       │   ├── entities/               # 实体系统
│       │   │   ├── player/
│       │   │   │   └── player_controller.dart
│       │   │   └── entities_system.dart
│       │   ├── world/                  # 世界系统
│       │   │   ├── voxel_world.dart
│       │   │   ├── chunk_manager.dart
│       │   │   └── voxel_types.dart
│       │   ├── rendering/
│       │   │   └── renderer_3d.dart
│       │   ├── managers/               # 管理器
│       │   │   ├── game_state_manager.dart
│       │   │   └── resource_manager.dart
│       │   ├── save_system/
│       │   │   └── world_save_manager.dart
│       │   ├── ui/
│       │   │   └── hud/
│       │   │       └── hud_widget.dart
│       │   └── menu/
│       │       └── main_menu.dart
│       └── main.dart
├── .github/
│   └── workflows/
│       └── build.yml                   # CI/CD 配置
└── pubspec.yaml
```

## 开发计划

### Phase 1 - 核心玩法
- [x] 程序化地形生成
- [x] 方块交互系统
- [x] 玩家移动和物理
- [x] 基础 UI/HUD

### Phase 2 - 扩展内容
- [ ] Crafting 系统
- [ ] 更多生物类型
- [ ] 物品栏深度管理
- [ ] 成就系统

### Phase 3 - 高级功能
- [ ] 多人联机
- [ ] 地图编辑器
- [ ] 模组支持
- [ ] 性能优化

## 技术栈

- **引擎**: Flutter + Flame
- **图形**: Flutter GPU (实验性 3D)
- **存储**: SQLite + SharedPreferences
- **状态管理**: Provider + Riverpod
- **CI/CD**: GitHub Actions

## 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 致谢

- [Flutter](https://flutter.dev) - 跨平台框架
- [Flame Engine](https://flame-engine.org) - 游戏引擎
- [Perlin Noise](https://en.wikipedia.org/wiki/Perlin_noise) - 程序化生成算法

---

<div align="center">
  <p>Made with ❤️ by EcoVerse Team</p>
</div>
