import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      width: double.infinity,
      child: Text(
        text.isNotEmpty ? text : "Empty bio...",
        style: TextStyle(color: theme.colorScheme.inversePrimary),
      ),
    );
  }
}
