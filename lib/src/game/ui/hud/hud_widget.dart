import 'package:flutter/material.dart';
import '../managers/game_state_manager.dart';
import '../voxel_types.dart';

/// HUD overlay widget displayed during gameplay
class HudWidget extends StatelessWidget {
  const HudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateManager>();
    
    return Stack(
      children: [
        // Notification popup
        if (gameState.notification.isNotEmpty)
          _buildNotification(gameState.notification),
        
        // Bottom hint bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildHintBar(context),
        ),
      ],
    );
  }
  
  Widget _buildNotification(String message) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHintBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHintItem(Icons.keyboard, 'WASD 移动'),
          const SizedBox(width: 16),
          _buildHintItem(Icons.fingerprint, '左键 挖掘'),
          const SizedBox(width: 16),
          _buildHintItem(Icons.place, '右键 放置'),
          const SizedBox(width: 16),
          _buildHintItem(Icons.inventory_2, 'E 背包'),
          const SizedBox(width: 16),
          _buildHintItem(Icons.play_circle, 'C 切换模式'),
        ],
      ),
    );
  }
  
  Widget _buildHintItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
