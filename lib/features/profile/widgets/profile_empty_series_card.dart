import 'package:flutter/material.dart';

class EmptySeriesCard extends StatelessWidget {

  const EmptySeriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.tv_off_outlined,
            size: 42,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune série suivie',
            style:
                theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez une série pour commencer à suivre votre progression.',
            textAlign: TextAlign.center,
            style:
                theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}