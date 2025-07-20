import 'package:ali_grad/constants/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_box.dart';

class StateCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const StateCard(
      {required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MyBox(
        boxPadding: AppTheme.paddingMedium,
        boxChild: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: count.toDouble()),
              duration: const Duration(milliseconds: 1800),
              builder: (_, value, __) => Text(
                value.toInt().toString(),
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
