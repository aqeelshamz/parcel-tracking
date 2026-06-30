import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/shipment.dart';
import '../providers/shipments_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/entrance.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/shimmer.dart';
import '../widgets/shipment_actions_sheet.dart';
import '../widgets/shipment_card.dart';
import 'settings_screen.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  int _navIndex = 0;
  int _tabIndex = 0; // 0 = Active, 1 = Archive
  bool _searching = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAdd() => Get.toNamed(AppRoutes.addShipment);

  void _openTrack(Shipment s) =>
      Get.toNamed(AppRoutes.trackPackage, arguments: s.id);

  List<Shipment> _filter(List<Shipment> list) {
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.trackingNumber.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _navIndex == 0 ? _buildHome(context) : const SettingsView(),
      ),
      floatingActionButton: _showFab(context) ? _buildFab() : null,
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onChanged: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  bool _showFab(BuildContext context) {
    if (_navIndex != 0 || _tabIndex != 0) return false;
    return context.watch<ShipmentsProvider>().active.isNotEmpty;
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        _openAdd();
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(FeatherIcons.plus, size: 28),
    );
  }

  Widget _buildHome(BuildContext context) {
    final provider = context.watch<ShipmentsProvider>();
    final list = _filter(_tabIndex == 0 ? provider.active : provider.archived);

    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
          child: SegmentedTabs(
            segments: const ['Active', 'Archive'],
            selected: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              HapticFeedback.lightImpact();
              return provider.refresh();
            },
            child: provider.isRefreshing && list.isEmpty
                ? const _SkeletonList()
                : list.isEmpty
                    ? _buildEmpty(context)
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => Entrance(
                          delay: Duration(milliseconds: 50 * i),
                          child: _buildDismissible(context, provider, list[i]),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: _searching
                ? _buildSearchField()
                : Text(
                    'My Shipments',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: context.c.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          if (_searching)
            AppIconButton(
              icon: FeatherIcons.x,
              onTap: () => setState(() {
                _searching = false;
                _query = '';
                _searchCtrl.clear();
              }),
            )
          else
            AppIconButton(
              icon: FeatherIcons.search,
              tooltip: 'Search',
              onTap: () => setState(() => _searching = true),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.c.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(FeatherIcons.search, color: context.c.textMuted, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              cursorColor: AppColors.primary,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search name or tracking number',
                hintStyle: TextStyle(color: context.c.textMuted, fontSize: 14),
              ),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: context.c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.10),
        if (_tabIndex == 0)
          Entrance(
            child: EmptyState(
              title: 'No packages yet',
              message:
                  "Add a tracking number from any courier and we'll keep you posted at every step.",
              ctaLabel: 'Track Your First Shipment',
              onCta: _openAdd,
            ),
          )
        else
          const Entrance(
            child: EmptyState(
              title: 'Nothing archived',
              message:
                  'Delivered or hidden shipments will appear here when you archive them.',
            ),
          ),
      ],
    );
  }

  Widget _buildDismissible(
      BuildContext context, ShipmentsProvider provider, Shipment s) {
    final archiving = _tabIndex == 0;
    return Dismissible(
      key: ValueKey(s.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: (archiving ? AppColors.warning : const Color(0xFFE5484D))
              .withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          archiving ? FeatherIcons.archive : FeatherIcons.trash2,
          color: archiving ? AppColors.warning : const Color(0xFFE5484D),
        ),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        if (archiving) {
          provider.setArchived(s.id, true);
          _snack('${s.name} archived', () => provider.setArchived(s.id, false));
        } else {
          provider.remove(s.id);
          _snack('${s.name} removed', null);
        }
      },
      child: ShipmentCard(
        shipment: s,
        onTap: () => _openTrack(s),
        onLongPress: () => ShipmentActionsSheet.show(context, s),
      ),
    );
  }

  void _snack(String message, VoidCallback? onUndo) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onUndo != null)
            GestureDetector(
              onTap: () {
                onUndo();
                if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
              },
              child: const Text(
                'UNDO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.toast,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => const ShipmentSkeleton(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surface,
        border: Border(top: BorderSide(color: context.c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(context, 0, FeatherIcons.home, 'Home'),
              _item(context, 1, FeatherIcons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, IconData icon, String label) {
    final selected = index == i;
    final color = selected ? AppColors.primary : context.c.textMuted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!selected) HapticFeedback.selectionClick();
          onChanged(i);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
