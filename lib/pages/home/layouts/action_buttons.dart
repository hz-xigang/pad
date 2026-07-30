import 'package:flutter/material.dart';

import '../../../http/ProdTagApi.dart';
import '../../../util/dialog_util.dart';
import '../../../util/feedback_util.dart';
import '../../../util/printer/print_service.dart';
import '../state/home_state.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.state});

  final HomeState state;

  void _handlePrint(BuildContext context) async {
    // 验证生产订单
    if (state.productionOrder == null) {
      FeedbackUtil.showError('未扫描生产订单号');
      return;
    }

    // 验证输入有效性
    if (!state.inputValid()) {
      return;
    }

    // 确认提交
    final bool confirmed = await DialogUtil.showConfirmDialog(
      context,
      content: '确认提交打印吗？',
      confirmText: '确认',
    );

    if (!confirmed) {
      return;
    }

    // 提交数据
    final Map<String, dynamic> res = {
      'prodOrderId': state.productionOrder!.id,
      'grossWeight': double.parse(state.grossWeight.trim()),
      'netWeight': double.parse(state.netWeight.trim()),
      'qty': int.parse(state.quantity.trim()),
    };

    try {
      FeedbackUtil.showLoading('上传中...');
      final AddTagResult result = await ProdTagApi.add(res);

      if (result.needsPrint) {
        // 后端返回 PDF 流，直接打印。
        FeedbackUtil.showLoading('打印中...');
        final PrintResult printResult = await PrintService().printPdf(
          pdfBytes: result.pdfBytes!,
        );
        if (printResult.success) {
          FeedbackUtil.showSuccess('打印成功');
          //state.clearForm();
        } else {
          FeedbackUtil.showError(
            '打印失败：${printResult.errorMessage ?? '未知错误'}',
          );
        }
      } else {
        // 后端返回 JSON，无需打印。
        FeedbackUtil.showSuccess(result.message ?? '提交成功');
        state.clearForm();
      }
    } catch (e) {
      FeedbackUtil.showError('上传失败：${e.toString()}');
    }
  }

  void _handleShowList(BuildContext context) {
    Navigator.pushNamed(context, '/tagList');
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
