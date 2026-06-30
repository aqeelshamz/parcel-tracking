import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Card with an icon, title, description and a trailing switch — used for the
/// "Push Notifications" preference on the Add Shipment screen.
class NotificationToggleCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggleCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.c.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.c.shadow,
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.c.chipTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              FeatherIcons.bell,
              color: AppColors.primaryDark,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.c.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Get notified on every delivery update.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: context.c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
