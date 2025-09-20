import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonTone { primary, secondary, tonal, surface }

class CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final ButtonTone tone;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.tone = ButtonTone.surface,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, fg, border) = switch (widget.tone) {
      ButtonTone.primary => (cs.primary, cs.onPrimary, null),
      ButtonTone.secondary => (
          cs.secondaryContainer,
          cs.onSecondaryContainer,
          null
        ),
      ButtonTone.tonal => (cs.errorContainer, cs.onErrorContainer, null),
      ButtonTone.surface => (
          cs.surfaceContainerHighest,
          cs.onSurface,
          cs.outlineVariant
        ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Size text based on actual box; clamp for sanity.
        final fs = (0.42 * (w < h ? w : h)).clamp(14.0, 28.0);

        // Remove big fixed paddings; let the box height breathe.
        final content = Center(
          child: Text(
            widget.label,
            locale: const Locale('en'), // ensure Latin digits here too
            textAlign: TextAlign.center,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: true,
              applyHeightToLastDescent: true,
              leadingDistribution: TextLeadingDistribution.even,
            ),
            style: TextStyle(
              fontSize: fs,
              height: 1.0, // no extra line gap → no crop
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        );

        // Lock OS text scaling just for labels so they never overflow.
        final mq = MediaQuery.of(context);
        final noScale = mq.copyWith(textScaler: const TextScaler.linear(1.0));

        return AnimatedScale(
          duration: const Duration(milliseconds: 90),
          scale: _pressed ? 0.98 : 1.0,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: border == null
                    ? BorderSide.none
                    : BorderSide(color: border),
              ),
              shadows: [
                if (widget.tone == ButtonTone.surface)
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _pressed = false);
                  widget.onTap();
                },
                child: MediaQuery(data: noScale, child: content),
              ),
            ),
          ),
        );
      },
    );
  }
}
