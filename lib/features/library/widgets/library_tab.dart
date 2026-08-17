import 'package:flutter/material.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    color: color,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              height: 2,
              width: double.infinity,
              color: selected
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}