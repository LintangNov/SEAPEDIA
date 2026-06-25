import 'package:flutter/material.dart';

class DebugBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final String label;

  const DebugBorder({
    super.key,
    required this.child,
    this.color = Colors.red,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(8.0), child: child),
          if (label.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                color: color,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
