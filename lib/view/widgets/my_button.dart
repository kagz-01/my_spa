import 'package:flutter/material.dart';

Widget myButton({
  required VoidCallback onPressed,
  required String label,
  IconData? icon, // Optional icon parameter
  Color color = Colors.teal, // Default button color
  Color textColor = Colors.white,
  double fontSize = 16, // Default font size
  FontWeight fontWeight = FontWeight.w600,
  double minWidth = 200, // Adjustable width
  double padding = 12, // Adjustable padding
  double borderRadius = 30,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon != null
        ? Icon(icon, color: textColor)
        : const SizedBox(), // Show icon if provided
    label: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight, // ✅ Use the customizable font weight
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: padding * 2, vertical: padding),
      minimumSize: Size(minWidth, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}
