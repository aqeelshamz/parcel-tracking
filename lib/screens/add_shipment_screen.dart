import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/courier.dart';
import '../models/shipment.dart';
import '../models/tracking_event.dart';
import '../providers/shipments_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/courier_avatar.dart';
import '../widgets/courier_picker_sheet.dart';
import '../widgets/notification_toggle_card.dart';
import '../widgets/primary_button.dart';

class AddShipmentScreen extends StatefulWidget {
  const AddShipmentScreen({super.key});

  @override
  State<AddShipmentScreen> createState() => _AddShipmentScreenState();
}

class _AddShipmentScreenState extends State<AddShipmentScreen> {
  final _trackingCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  Courier? _courier;
  bool _notify = true;

  @override
  void dispose() {
    _trackingCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      _trackingCtrl.text.trim().isNotEmpty && _courier != null;

  Future<void> _pickCourier() async {
    FocusScope.of(context).unfocus();
    final picked =
        await CourierPickerSheet.show(context, selectedId: _courier?.id);
    if (picked != null) setState(() => _courier = picked);
  }

  void _autoDetect() {
    final guess = Courier.autoDetect(_trackingCtrl.text);
    if (guess == null) {
      _toast('Enter a tracking number first');
      return;
    }
    setState(() => _courier = guess);
    _toast('Detected ${guess.name}');
  }

  void _scan() => _toast('Scanner coming soon');

  void _submit() {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final name =
        _nameCtrl.text.trim().isEmpty ? 'New Shipment' : _nameCtrl.text.trim();
    final shipment = Shipment(
      id: 's_${now.microsecondsSinceEpoch}',
      name: name,
      trackingNumber: _trackingCtrl.text.trim(),
      courierId: _courier!.id,
      status: ShipmentStatus.pending,
      expectedDelivery: now.add(const Duration(days: 3)),
      notifyEnabled: _notify,
      events: [
        TrackingEvent(
          stage: TrackingStage.orderCreated,
          location: 'Order registered',
          time: now,
        ),
      ],
    );
    context.read<ShipmentsProvider>().add(shipment);
    Get.back<void>();
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Text(
        '$name added to your shipments',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.toast,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }

  void _toast(String msg) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Text(
        msg,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.toast,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Add Shipment'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  AppTextField(
                    label: 'Tracking Number',
                    hint: 'e.g. JB123456789',
                    controller: _trackingCtrl,
                    capitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() {}),
                    trailing: _ScanButton(onTap: _scan),
                  ),
                  const SizedBox(height: 22),
                  _CourierField(courier: _courier, onTap: _pickCourier),
                  const SizedBox(height: 10),
                  _AutoDetectButton(onTap: _autoDetect),
                  const SizedBox(height: 22),
                  AppTextField(
                    label: 'Shipment Name',
                    hint: 'e.g. Headphones',
                    controller: _nameCtrl,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  NotificationToggleCard(
                    value: _notify,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _notify = v);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: PrimaryButton(
                label: 'Add Shipment',
                onPressed: _valid ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: context.c.chipTint,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(FeatherIcons.maximize,
                color: AppColors.primary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _CourierField extends StatelessWidget {
  final Courier? courier;
  final VoidCallback onTap;

  const _CourierField({required this.courier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Courier Provider',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.c.textPrimary,
          ),
        ),
        const SizedBox(height: 9),
        Material(
          color: context.c.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.c.border, width: 1.2),
              ),
              child: Row(
                children: [
                  if (courier != null) ...[
                    CourierAvatar(courier: courier, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      courier!.name,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: context.c.textPrimary,
                      ),
                    ),
                  ] else
                    Text(
                      'Select Courier',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.c.textMuted,
                      ),
                    ),
                  const Spacer(),
                  Icon(FeatherIcons.chevronDown,
                      color: context.c.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AutoDetectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AutoDetectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FeatherIcons.zap, size: 17, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            'Auto-detect courier',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
