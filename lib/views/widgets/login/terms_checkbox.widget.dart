import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final int animationDelay;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    this.animationDelay = 1500,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: animationDelay),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue ?? false);
            },
            activeColor: Colors.orange[900],
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onChanged(!value),
                  child: Text(
                    "Aceito os ",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: onTermsTap,
                  child: Text(
                    "termos de responsabilidade",
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onChanged(!value),
                  child: Text(
                    " e uso do aplicativo",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
