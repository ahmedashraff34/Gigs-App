import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? showBackButton;
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      automaticallyImplyLeading: showBackButton != null ? true : false,
      elevation: 4,
      backgroundColor: AppTheme.primaryColor,
      title: Center(
        child: Text(
          title,
          style: AppTheme.textStyle0.copyWith(
              color: AppTheme.textColor2, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
