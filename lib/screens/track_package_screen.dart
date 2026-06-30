import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/courier.dart';
import '../models/shipment.dart';
import '../providers/shipments_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../utils/formatters.dart';
import '../widgets/app_header.dart';
import '../widgets/courier_avatar.dart';
import '../widgets/entrance.dart';
import '../widgets/shimmer.dart';
import '../widgets/shipment_actions_sheet.dart';
import '../widgets/status_badge.dart';
import '../widgets/tracking_timeline.dart';

class TrackPackageScreen extends StatelessWidget {
  const TrackPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    final provider = context.watch<ShipmentsProvider>();
    final shipment = id == null ? null : provider.byId(id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Track Package',
              trailing: shipment == null
                  ? null
                  : _MoreButton(
                      onTap: () =>
                          ShipmentActionsSheet.show(context, shipment),
                    ),
            ),
            Expanded(
              child: shipment == null
                  ? const _NotFound()
                  : _TrackBody(shipment: shipment),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.c.surfaceMuted,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(FeatherIcons.moreHorizontal,
              size: 22, color: context.c.textPrimary),
        ),
      ),
    );
  }
}

class _TrackBody extends StatelessWidget {
  final Shipment shipment;

  const _TrackBody({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentsProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Entrance(child: _SummaryCard(shipment: shipment)),
        const SizedBox(height: 24),
        Entrance(
          delay: const Duration(milliseconds: 80),
          child: Row(
            children: [
              Text(
                'Tracking History',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: context.c.textPrimary,
                ),
              ),
              const Spacer(),
              if (provider.lastUpdated != null && !provider.isRefreshing) ...[
                Text(
                  'Updated ${Formatters.relative(provider.lastUpdated!)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.c.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              _RefreshButton(
                spinning: provider.isRefreshing,
                onTap: provider.isRefreshing
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        provider.refresh();
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Entrance(
          delay: const Duration(milliseconds: 140),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              color: context.c.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.c.border),
            ),
            child: provider.isRefreshing
                ? const _TimelineSkeleton()
                : TrackingTimeline(shipment: shipment),
          ),
        ),
      ],
    );
  }
}

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == 4 ? 0 : 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SkeletonBox(width: 42, height: 11),
                      SizedBox(height: 5),
                      SkeletonBox(width: 34, height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const SkeletonBox(width: 13, height: 13, radius: 7),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 130, height: 13),
                    SizedBox(height: 7),
                    SkeletonBox(width: 90, height: 11),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Shipment shipment;

  const _SummaryCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final courier = Courier.byId(shipment.courierId);
    final eta = shipment.expectedDelivery;
    final delivered = shipment.status == ShipmentStatus.delivered;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.c.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.c.shadow, // 0 8px 22px rgba(16,24,40,.05)
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'courier-${shipment.id}',
                child: CourierAvatar(courier: courier, size: 52),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _copyTracking(context),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              shipment.trackingNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.c.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(FeatherIcons.copy,
                              size: 13, color: context.c.textMuted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: shipment.status),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: context.c.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                delivered ? 'Delivered on' : 'Expected delivery',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: context.c.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                eta == null ? '—' : Formatters.dayMonthTime(eta),
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: context.c.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyTracking(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shipment.trackingNumber));
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: const Text(
        'Tracking number copied',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.toast,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final bool spinning;
  final VoidCallback? onTap;

  const _RefreshButton({required this.spinning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          spinning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : const Icon(FeatherIcons.refreshCw,
                  size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          const Text(
            'Refresh',
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

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'This shipment is no longer available.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.c.textSecondary,
          ),
        ),
      ),
    );
  }
}
