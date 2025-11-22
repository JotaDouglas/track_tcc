import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final int animationDelay;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.animationDelay = 1600,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: animationDelay),
      child: MaterialButton(
        onPressed: onPressed,
        height: 50,
        color: Colors.orange[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
