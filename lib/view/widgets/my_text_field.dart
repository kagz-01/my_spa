import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for TextInputFormatter

Widget textField({
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  bool obscureText = false,
  bool isPassword = false, // Show toggle eye icon for passwords
  TextInputType keyboardType = TextInputType.text, // Default keyboard type
  Color fillColor = Colors.white, // Default background color
  Color borderColor = Colors.grey, // Default border color
  double borderRadius = 12.0, // Default border radius
  Function(String)? validator, // Added validation support
  Function(String)? onSubmitted, // Added submission handler
  FocusNode? focusNode, // Added focus node support
  List<TextInputFormatter>? inputFormatters, // Added input formatters
}) {
  // For Linux keyboard input issue workaround
  final inputTextEditingController = controller;

  return StatefulBuilder(
    builder: (context, setState) {
      return TextField(
        controller: inputTextEditingController,
        obscureText: obscureText, // Hide text for passwords
        keyboardType: keyboardType,
        onSubmitted: onSubmitted, // Handle form submission
        focusNode: focusNode, // Handle focus management
        inputFormatters:
            inputFormatters, // Add input formatters for additional control
        // Enable backspace key behavior
        enableInteractiveSelection: true,
        // Handle key events for Linux
        onChanged: (text) {
          // This forces the widget to update on each keystroke
          inputTextEditingController.value =
              inputTextEditingController.value.copyWith(
            text: text,
            selection: inputTextEditingController.selection,
            composing: TextRange.empty,
          );
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]), // Hint text color
          filled: true,
          fillColor: fillColor, // Background color
          prefixIcon: Icon(icon, color: Colors.grey), // Leading icon

          // Show eye toggle button if it's a password field
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => obscureText = !obscureText),
                )
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      );
    },
  );
}
