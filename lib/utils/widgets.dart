import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class MyTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  MyTextButton({ Key? key, required this.text, required this.onPressed }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text(this.text.toUpperCase()),
        onPressed: this.onPressed
    );
  }
}
