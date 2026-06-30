import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

import '../models/courier.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'courier_avatar.dart';

/// Bottom-sheet courier selector with search. Returns the chosen [Courier].
class CourierPickerSheet extends StatefulWidget {
  final String? selectedId;

  const CourierPickerSheet({super.key, this.selectedId});

  static Future<Courier?> show(BuildContext context, {String? selectedId}) {
    return showModalBottomSheet<Courier>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourierPickerSheet(selectedId: selectedId),
    );
  }

  @override
  State<CourierPickerSheet> createState() => _CourierPickerSheetState();
}

class _CourierPickerSheetState extends State<CourierPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = Courier.all
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        decoration: BoxDecoration(
          color: context.c.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Select Courier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.c.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(FeatherIcons.x,
                        color: context.c.textMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'Search couriers',
                  prefixIcon: Icon(FeatherIcons.search,
                      color: context.c.textMuted),
                  filled: true,
                  fillColor: context.c.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (context, i) {
                  final c = results[i];
                  final selected = c.id == widget.selectedId;
                  return ListTile(
                    onTap: () => Navigator.pop(context, c),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: CourierAvatar(courier: c, size: 42),
                    title: Text(
                      c.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.c.textPrimary,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(FeatherIcons.checkCircle,
                            color: AppColors.primary)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
