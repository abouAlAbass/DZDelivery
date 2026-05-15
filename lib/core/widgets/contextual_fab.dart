import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ContextualFab extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;
  final String? label;

  const ContextualFab({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bottomOffset = width < AppBreakpoints.tablet
        ? 72.0 + safeBottom
        : width < AppBreakpoints.desktop
        ? AppSpacing.md
        : AppSpacing.lg;

    final fab = label == null
        ? FloatingActionButton(
            onPressed: onPressed,
            tooltip: tooltip,
            child: Icon(icon),
          )
        : FloatingActionButton.extended(
            onPressed: onPressed,
            tooltip: tooltip,
            icon: Icon(icon),
            label: Text(label!),
          );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomOffset),
      child: fab,
    );
  }
}
