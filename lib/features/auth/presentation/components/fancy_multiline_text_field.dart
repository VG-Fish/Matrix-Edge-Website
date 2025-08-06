import 'package:flutter/material.dart';

class FancyMultilineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const FancyMultilineTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: null,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.tertiary),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),

        hintText: hintText,
        hintStyle: TextStyle(color: theme.colorScheme.primary),

        filled: true,
        fillColor: theme.colorScheme.secondary,
      ),
    );
  }
}
