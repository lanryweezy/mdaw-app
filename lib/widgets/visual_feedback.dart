import 'package:flutter/material.dart';

class GlowingTrackBorder extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const GlowingTrackBorder({
    super.key,
    required this.isSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00D4FF).withAlpha(15) : Colors.transparent,
        border: isSelected
            ? Border.all(color: const Color(0xFF00D4FF), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: child,
    );
  }
}
