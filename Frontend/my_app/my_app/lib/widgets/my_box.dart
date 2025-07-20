import 'package:flutter/cupertino.dart';
import '../constants/theme.dart';

class MyBox extends StatelessWidget {
  final Widget? boxChild;
  final double boxPadding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderWidth;
  final AlignmentGeometry alignment;

  const MyBox({
    Key? key,
    required this.boxChild,
    required this.boxPadding,
    this.margin,
    this.width,
    this.height,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width, // null = auto width
      height: height, // null = auto height
      alignment: alignment,
      decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.cardColor,
          borderRadius: AppTheme.borderRadiusLarge,
          boxShadow: AppTheme.cardShadow,
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  width: borderWidth != null ? borderWidth! : 1.0,
                )
              : AppTheme.cardBorder),
      child: Padding(
        padding: EdgeInsets.all(boxPadding),
        child: boxChild,
      ),
    );
  }
}
