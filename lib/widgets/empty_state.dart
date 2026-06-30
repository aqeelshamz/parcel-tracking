import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../theme/app_palette.dart';
import 'parcel_illustration.dart';
import 'primary_button.dart';

/// Centered empty state: parcel illustration, title, subtitle and an optional
/// primary CTA.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ParcelIllustration(size: 148),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: context.c.textSecondary,
              ),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 28),
              PrimaryButton(
                label: ctaLabel!,
                icon: FeatherIcons.plus,
                onPressed: onCta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
