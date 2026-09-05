import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isOffline;
  final String? message;

  const ConnectivityBanner({
    super.key,
    required this.isOffline,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && (message == null || message!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final isWarning = isOffline;
    final bgColor = isWarning ? AppTheme.warningColor : AppTheme.secondaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(color: bgColor.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.wifi_off_rounded : Icons.info_outline_rounded,
            size: 18,
            color: bgColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message ?? (isOffline ? 'You are offline. Showing cached products.' : ''),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isWarning ? AppTheme.warningColor : AppTheme.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
