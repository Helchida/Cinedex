import 'package:flutter/material.dart';

class Backdrop extends StatelessWidget {
  const Backdrop({
    super.key,
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.tv,
            color: Colors.white,
            size: 64,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://image.tmdb.org/t/p/w780$path',
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}