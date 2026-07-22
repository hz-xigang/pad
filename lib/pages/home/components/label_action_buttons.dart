import 'package:flutter/material.dart';

class LabelActionButtons extends StatelessWidget {
  const LabelActionButtons({
    super.key,
    required this.onPrint,
    required this.onShowList,
    required this.onClear,
  });

  final VoidCallback onPrint;
  final VoidCallback onShowList;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onPrint,
          icon: const Icon(Icons.print, size: 18),
          label: const Text('打印标签'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D63F0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onShowList,
          icon: const Icon(Icons.list, size: 18),
          label: const Text('标签列表'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3D63F0),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            side: const BorderSide(color: Color(0xFF3D63F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.clear, size: 18),
          label: const Text('清空表单'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3D63F0),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            side: const BorderSide(color: Color(0xFF3D63F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
