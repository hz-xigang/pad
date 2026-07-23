import 'package:flutter/material.dart';

import '../components/label_display_field.dart';
import '../components/label_input_field.dart';
import '../state/home_state.dart';

class InfoSection extends StatefulWidget {
  const InfoSection({
    super.key,
    required this.state,
    required this.keyboardFocusNode,
  });

  final HomeState state;
  final FocusNode keyboardFocusNode;

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  late final TextEditingController _productionNoController;

  @override
  void initState() {
    super.initState();
    _productionNoController = TextEditingController();
    _productionNoController.addListener(() {
      widget.state.setProductionNo(_productionNoController.text);
    });
    // 监听 state 变化，同步更新输入框
    widget.state.addListener(_syncController);
  }

  @override
  void dispose() {
    widget.state.removeListener(_syncController);
    _productionNoController.dispose();
    super.dispose();
  }

  void _syncController() {
    // 如果 state 的值与 controller 不同，更新 controller（避免循环）
    if (_productionNoController.text != widget.state.productionNo) {
      _productionNoController.value = TextEditingValue(
        text: widget.state.productionNo,
        selection: TextSelection.collapsed(offset: widget.state.productionNo.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一行：生产单号、用友单号、客户编码、存货编码
        Row(
          children: [
            Expanded(
              child: LabelInputField(
                label: '生产单号',
                required: true,
                controller: _productionNoController,
                placeholder: '请输入生产单号,回车查询...',
                onSubmitted: (_) {
                  widget.state.searchProductionOrder();
                  // 查询完成后，重新获取焦点以便扫描枪继续输入
                  Future.delayed(const Duration(milliseconds: 100), () {
                    widget.keyboardFocusNode.requestFocus();
                  });
                },
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF3D63F0)),
                  onPressed: () {
                    widget.state.searchProductionOrder();
                    // 点击搜索后也重新获取焦点
                    Future.delayed(const Duration(milliseconds: 100), () {
                      widget.keyboardFocusNode.requestFocus();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabelDisplayField(
                label: '用友单号',
                value: widget.state.productionOrder?.erpOrderNo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabelDisplayField(
                label: '客户编码',
                value: widget.state.productionOrder?.customerCode,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabelDisplayField(
                label: '存货编码',
                value: widget.state.productionOrder?.inventoryCode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 第二行：存货名称、客户料号、规格型号、产品材质
        Row(
          children: [
            Expanded(
              child: LabelDisplayField(
                label: '存货名称',
                value: widget.state.productionOrder?.inventoryName,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabelDisplayField(
                label: '客户料号',
                value: widget.state.productionOrder?.custMaterialNo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabelDisplayField(
                label: '规格型号',
                value: widget.state.productionOrder?.spec,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LabelDisplayField(
                label: '产品材质',
                value: widget.state.productionOrder?.material,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 第三行：产品类别
        Row(
          children: [
            Expanded(
              child: LabelDisplayField(
                label: '产品类别',
                value: widget.state.productionOrder?.productCategory,
              ),
            ),
            const Expanded(flex: 3, child: SizedBox()),
          ],
        ),
      ],
    );
  }
}
