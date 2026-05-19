import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: isDestructive ? Theme.of(context).colorScheme.error : null,
      ),
      child: child,
    );
  }
}
