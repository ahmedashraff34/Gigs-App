import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/theme.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const SubmitButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: AppTheme.lightAccentColor),
        ),
      ),
    );
  }
}
