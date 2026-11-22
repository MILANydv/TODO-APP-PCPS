import 'package:flutter/material.dart';

/// Reusable text field with consistent styling and a label above the input.
///
/// Wraps a [TextFormField] inside a [Column] with a [Text] label, providing
/// a uniform look across login, register, and task forms.
class CustomTextField extends StatelessWidget {
  /// Controller backing the text input.
  final TextEditingController controller;

  /// Label text displayed above the field.
  final String label;

  /// Placeholder hint shown inside the empty field.
  final String hint;

  /// Whether the text should be obscured (e.g. for passwords).
  final bool obscureText;

  /// Keyboard type to request (e.g. email address, plain text).
  final TextInputType keyboardType;

  /// Optional validation function called by the parent form.
  final String? Function(String?)? validator;

  /// Optional icon shown at the start of the field.
  final IconData? icon;

  /// Creates a [CustomTextField] with the given [controller] and [label].
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
