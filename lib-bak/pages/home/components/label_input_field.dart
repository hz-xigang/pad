import 'package:flutter/material.dart';

class LabelInputField extends StatelessWidget {
  const LabelInputField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.placeholder,
    this.suffixIcon,
    this.onSubmitted,
  });

  final String label;
  final bool required;
  final TextEditingController controller;
  final String? placeholder;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final labelColor = required ? const Color(0xFFFF6B00) : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (required)
              Text(
                '* ',
                style: TextStyle(
                  fontSize: 14,
                  color: labelColor,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(color: Color(0xFF3D63F0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: suffixIcon,
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入$label';
                  }
                  return null;
                }
              : null,

        ),
      ],
    );
  }
}
