import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/theme.dart';
import 'my_box.dart';

class MyBadge extends StatelessWidget {
  final String name;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;

  const MyBadge({
    super.key,
    required this.name,
    required this.date,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizes
    final double iconSize = screenWidth * 0.05; // ~30-40 depending on phone
    final double containerSize = screenWidth * 0.10;
    final double textSize = screenWidth * 0.040;

    return MyBox(
      boxPadding: AppTheme.paddingMedium,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      boxChild: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Container(
          //   width: containerSize,
          //   height: containerSize,
          //   decoration: BoxDecoration(
          //     color: iconColor.withOpacity(0.2),
          //     shape: BoxShape.circle,
          //   ),
          //   child: Center(
          //     child: Icon(icon, color: iconColor, size: iconSize),
          //   ),
          // ),
          // SizedBox(height: screenWidth * 0.01),
          Text(
            date,
            style: textStyle != null
                ? textStyle
                : TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: textSize,
                  ),
          ),
          Text(
            name,
            style: textStyle != null
                ? textStyle
                : TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: textSize,
                  ),
          ),
        ],
      ),
    );
  }
}
