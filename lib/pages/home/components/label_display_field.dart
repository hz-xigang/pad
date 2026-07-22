import 'package:flutter/material.dart';

class LabelDisplayField extends StatelessWidget {
  const LabelDisplayField({
    super.key,
    required this.label,
    this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '自动带出',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3D63F0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value ?? '自动填充',
            style: TextStyle(
              fontSize: 14,
              color: value != null ? Colors.black87 : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
