import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Standalone Settings route (also reachable as a tab via [SettingsView]).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: SettingsView()),
    );
  }
}

/// Settings body — embedded in the home scaffold's bottom-nav and the route.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool _notifications =
      StorageService.getBool(StorageService.kNotifications, defaultValue: true);

  void _setNotifications(bool v) {
    HapticFeedback.selectionClick();
    setState(() => _notifications = v);
    StorageService.setBool(StorageService.kNotifications, v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: context.c.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 22),
        _section('Preferences', [
          _Row(
            icon: FeatherIcons.bell,
            title: 'Notifications',
            subtitle: 'Delivery alerts & updates',
            toggle: _notifications,
            onToggle: _setNotifications,
          ),
          _Row(
            icon: theme.isDark
                ? FeatherIcons.moon
                : FeatherIcons.sun,
            title: 'Dark mode',
            subtitle: theme.isDark ? 'On' : 'Off',
            toggle: theme.isDark,
            onToggle: (v) {
              HapticFeedback.selectionClick();
              context.read<ThemeProvider>().setDark(v);
            },
          ),
          const _Row(
            icon: FeatherIcons.globe,
            title: 'Language',
            subtitle: 'English',
          ),
        ]),
        const SizedBox(height: 18),
        _section('Support', const [
          _Row(icon: FeatherIcons.helpCircle, title: 'Help Center'),
          _Row(icon: FeatherIcons.star, title: 'Rate Latelogic'),
          _Row(
            icon: FeatherIcons.info,
            title: 'About',
            subtitle: 'v1.0.0 · ${AppConfig.env}',
          ),
        ]),
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: context.c.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.c.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                      indent: 60,
                      endIndent: 16,
                      height: 1,
                      color: context.c.border),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool? toggle;
  final ValueChanged<bool>? onToggle;

  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.toggle,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.c.chipTint,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: context.c.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: context.c.textMuted,
              ),
            ),
      trailing: toggle == null
          ? Icon(FeatherIcons.chevronRight, color: context.c.textMuted)
          : Switch(value: toggle!, onChanged: onToggle),
      onTap: toggle == null ? () {} : () => onToggle?.call(!toggle!),
    );
  }
}
