import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'package:flutter/services.dart';

class InputBox extends StatefulWidget {
  final String? label;
  final String hintText;
  final bool obscure;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool isNumber;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final Widget? suffixIcon;

  const InputBox({
    super.key,
    this.label,
    required this.hintText,
    required this.obscure,
    this.controller,
    this.onChanged,
    this.isNumber = false,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines,
    this.suffixIcon,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTheme.textStyle1.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.paddingSmall),
        ],
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType ??
              (widget.isNumber
                  ? TextInputType.numberWithOptions(decimal: true)
                  : null),
          inputFormatters: widget.inputFormatters ??
              (widget.isNumber
                  ? [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*\.?[0-9]*'))
                    ]
                  : null),
          minLines: widget.obscure ? 1 : widget.minLines,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTheme.textStyle2
                .copyWith(color: AppTheme.textColor1.withValues(alpha: .7)),
            filled: true,
            fillColor: widget.errorText != null
                ? Colors.red.withValues(alpha: 0.05)
                : AppTheme.dividerColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.paddingSmall),
              borderSide: widget.errorText != null
                  ? BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.paddingSmall),
              borderSide: widget.errorText != null
                  ? BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.paddingSmall),
              borderSide: widget.errorText != null
                  ? BorderSide(color: Colors.red, width: 1)
                  : BorderSide(color: AppTheme.primaryColor, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.paddingSmall),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.paddingSmall),
              borderSide: BorderSide.none,
            ),
            suffixIcon: widget.suffixIcon ?? (widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null),
            errorText: widget.errorText,
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: AppTheme.paddingSmall),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
