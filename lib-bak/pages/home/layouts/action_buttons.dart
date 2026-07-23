import 'package:flutter/material.dart';

import '../state/home_state.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.state});

  final HomeState state;

  void _handlePrint(BuildContext context) {
    if (state.validate()) {
      // TODO: 调用打印接口
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开始打印标签')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整的表单信息')),
      );
    }
  }

  void _handleShowList(BuildContext context) {
    // TODO: 跳转到标签列表页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看标签列表')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _handlePrint(context),
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
          onPressed: () => _handleShowList(context),
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
          onPressed: state.clearForm,
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
