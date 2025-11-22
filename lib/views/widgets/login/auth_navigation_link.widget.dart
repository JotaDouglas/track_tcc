import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AuthNavigationLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onPressed;
  final int animationDelay;

  const AuthNavigationLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onPressed,
    this.animationDelay = 1500,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: animationDelay),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              linkText,
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
