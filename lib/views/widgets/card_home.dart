import 'package:flutter/material.dart';

Widget buildCard({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? color,
  Color? iconColor,
  Color? textColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color ?? Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: iconColor ?? Colors.orange[900]),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
