import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/shipment.dart';
import '../providers/shipments_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Bottom-sheet of per-shipment actions: copy, mark delivered, rename,
/// archive/unarchive and delete.
class ShipmentActionsSheet extends StatelessWidget {
  final Shipment shipment;

  const ShipmentActionsSheet({super.key, required this.shipment});

  static Future<void> show(BuildContext context, Shipment shipment) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShipmentActionsSheet(shipment: shipment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ShipmentsProvider>();
    final delivered = shipment.status == ShipmentStatus.delivered;

    return Container(
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: context.c.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shipment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: context.c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _Action(
              icon: FeatherIcons.copy,
              label: 'Copy tracking number',
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: shipment.trackingNumber));
                _close('Tracking number copied');
              },
            ),
            if (!delivered)
              _Action(
                icon: FeatherIcons.checkCircle,
                label: 'Mark as delivered',
                onTap: () {
                  provider.markDelivered(shipment.id);
                  _close('Marked as delivered');
                },
              ),
            _Action(
              icon: FeatherIcons.edit2,
              label: 'Rename',
              onTap: () {
                Navigator.pop(context);
                _rename(context, provider);
              },
            ),
            _Action(
              icon: shipment.archived
                  ? FeatherIcons.archive
                  : FeatherIcons.archive,
              label: shipment.archived ? 'Move to Active' : 'Archive',
              onTap: () {
                provider.setArchived(shipment.id, !shipment.archived);
                _close(shipment.archived ? 'Moved to Active' : 'Archived');
              },
            ),
            _Action(
              icon: FeatherIcons.trash2,
              label: 'Delete',
              destructive: true,
              onTap: () {
                provider.remove(shipment.id);
                _close('Shipment deleted');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _close(String message) {
    HapticFeedback.selectionClick();
    if (Get.isBottomSheetOpen ?? false) Get.back<void>();
    _toast(message);
  }

  void _rename(BuildContext context, ShipmentsProvider provider) {
    final ctrl = TextEditingController(text: shipment.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename shipment',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.c.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: context.c.textMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.updateName(shipment.id, ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.toast,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFE5484D) : context.c.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
