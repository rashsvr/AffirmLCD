import 'dart:math';

import 'package:flutter/material.dart';

import 'affirmation_service.dart';
import 'widget_design.dart';

class WidgetPreview extends StatelessWidget {
  const WidgetPreview({super.key, required this.text, this.compact = false});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cleaned = text.trim().isEmpty
        ? AffirmationService.emptyListText
        : text.trim();
    final size = MediaQuery.sizeOf(context);
    final previewWidth = min<double>(size.width - 32, compact ? 300 : 420);
    final now = TimeOfDay.now();
    final label =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Semantics(
      label: cleaned,
      child: Container(
        width: previewWidth,
        constraints: BoxConstraints(minHeight: compact ? 118 : 148),
        padding: EdgeInsets.all(
          compact ? WidgetDesign.smallPadding : WidgetDesign.mediumPadding,
        ),
        decoration: BoxDecoration(
          color: WidgetDesign.lcdBackground,
          borderRadius: BorderRadius.circular(WidgetDesign.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: WidgetDesign.textMuted,
                fontFamily: WidgetDesign.fontFamily,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: compact ? 10 : 14),
            Text(
              '$cleaned ${WidgetDesign.suffixEmoji}',
              textAlign: TextAlign.center,
              maxLines: compact ? 3 : 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: WidgetDesign.textPrimary,
                fontFamily: WidgetDesign.fontFamily,
                fontSize: compact ? 22 : 28,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
