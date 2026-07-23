import 'package:flutter/material.dart';

import '../components/label_display_field.dart';
import '../components/label_input_field.dart';
import '../state/home_state.dart';

class InfoSection extends StatefulWidget {
  const InfoSection({
    super.key,
    required this.state,
  });

  final HomeState state;

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
  }

  @override
  void dispose() {
    _productionNoController.dispose();
    super.dispose();
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
                onSubmitted: (_) => widget.state.searchProductionOrder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF3D63F0)),
                  onPressed: widget.state.searchProductionOrder,
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
