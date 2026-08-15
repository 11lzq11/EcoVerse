import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/game_state_manager.dart';

/// Main menu screen shown before entering the game
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _hasSave = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _startNewWorld() async {
    final gameState = context.read<GameStateManager>();
    await gameState.startNewGame();
    if (mounted) {
      // Signal game to start
      Navigator.of(context).pop(true);
    }
  }
  
  void _loadWorld() async {
    final gameState = context.read<GameStateManager>();
    // Load world logic handled by game
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Title
                    _buildLogo(),
                    const SizedBox(height: 48),
                    
                    // Menu buttons
                    _buildMenuButton(
                      icon: Icons.play_arrow,
                      label: '开始新游戏',
                      onPressed: _startNewWorld,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildMenuButton(
                      icon: Icons.folder_open,
                      label: _hasSave ? '继续世界' : '没有找到存档',
                      onPressed: _hasSave ? _loadWorld : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildMenuButton(
                      icon: Icons.settings,
                      label: '设置',
                      onPressed: () => _showSettings(context),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildMenuButton(
                      icon: Icons.info_outline,
                      label: '关于',
                      onPressed: () => _showAbout(context),
                    ),
                    const SizedBox(height: 48),
                    
                    // Version info
                    Text(
                      '版本 1.0.0-alpha',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '灵境 EcoVerse - 开放创造式沙盒游戏',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogo() {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 120,
          color: Colors.greenAccent,
        ),
        const SizedBox(height: 16),
        const Text(
          '灵境',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 8,
          ),
        ),
        const Text(
          'EcoVerse',
          style: TextStyle(
            fontSize: 24,
            color: Colors.greenAccent,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '开放创造式沙盒游戏',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 280,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null 
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
          foregroundColor: onPressed != null 
            ? Colors.white 
            : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: onPressed != null 
                ? BorderSide(color: Colors.greenAccent.withOpacity(0.5))
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
  
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.volume_up),
                title: Text('音量'),
                subtitle: Slider(value: 0.8, onChanged: (_) {}),
              ),
              ListTile(
                leading: Icon(Icons.gamepad),
                title: Text('控制'),
                subtitle: Text('WASD移动，鼠标控制视角'),
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('语言'),
                subtitle: Text('中文'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('关于 灵境 EcoVerse'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '灵境 EcoVerse 是一款基于 Flutter 开发的开放创造式沙盒游戏。',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text('功能特性:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• 程序化生成的无限世界'),
              const Text('• 生存和创造模式'),
              const Text('• 建筑与 crafting 系统'),
              const Text('• 昼夜循环系统'),
              const Text('• 跨平台支持（Windows/macOS/iOS/Android）'),
              const SizedBox(height: 16),
              const Text('操作说明:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• WASD - 移动'),
              const Text('• 空格 - 跳跃'),
              const Text('• Shift - 冲刺/潜行'),
              const Text('• 鼠标左键 - 破坏方块'),
              const Text('• 鼠标右键 - 放置方块'),
              const Text('• E - 打开背包'),
              const Text('• C - 切换创造/生存模式'),
              const Text('• ESC - 暂停游戏'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
