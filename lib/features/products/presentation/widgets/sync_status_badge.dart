import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool isFromCache;
  final bool isOffline;

  const SyncStatusBadge({
    super.key,
    required this.isFromCache,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color textColor, IconData icon, String label) = switch ((isOffline, isFromCache)) {
      (true, _) => (
          AppTheme.warningColor.withOpacity(0.15),
          AppTheme.warningColor,
          Icons.cloud_off_rounded,
          'Offline Mode (Hive Cache)'
        ),
      (false, true) => (
          AppTheme.secondaryColor.withOpacity(0.15),
          AppTheme.secondaryColor,
          Icons.storage_rounded,
          'Loaded from Hive Cache'
        ),
      (false, false) => (
          AppTheme.accentColor.withOpacity(0.15),
          AppTheme.accentColor,
          Icons.cloud_done_rounded,
          'Live (FakeStore API via Retrofit)'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
