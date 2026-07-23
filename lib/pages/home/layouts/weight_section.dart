import 'package:flutter/material.dart';

import '../components/label_input_field.dart';
import '../state/home_state.dart';

class WeightSection extends StatefulWidget {
  const WeightSection({
    super.key,
    required this.state,
  });

  final HomeState state;

  @override
  State<WeightSection> createState() => _WeightSectionState();
}

class _WeightSectionState extends State<WeightSection> {
  late final TextEditingController _quantityController;
  late final TextEditingController _grossWeightController;
  late final TextEditingController _netWeightController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _grossWeightController = TextEditingController();
    _netWeightController = TextEditingController();

    _quantityController.addListener(() {
      widget.state.setQuantity(_quantityController.text);
    });
    _grossWeightController.addListener(() {
      widget.state.setGrossWeight(_grossWeightController.text);
    });
    _netWeightController.addListener(() {
      widget.state.setNetWeight(_netWeightController.text);
    });

    // 监听 state 变化，同步更新输入框
    widget.state.addListener(_syncControllers);
  }

  @override
  void dispose() {
    widget.state.removeListener(_syncControllers);
    _quantityController.dispose();
    _grossWeightController.dispose();
    _netWeightController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    // 同步单箱数量
    if (_quantityController.text != widget.state.quantity) {
      _quantityController.value = TextEditingValue(
        text: widget.state.quantity,
        selection: TextSelection.collapsed(offset: widget.state.quantity.length),
      );
    }

    // 同步毛重
    if (_grossWeightController.text != widget.state.grossWeight) {
      _grossWeightController.value = TextEditingValue(
        text: widget.state.grossWeight,
        selection: TextSelection.collapsed(offset: widget.state.grossWeight.length),
      );
    }

    // 同步净重
    if (_netWeightController.text != widget.state.netWeight) {
      _netWeightController.value = TextEditingValue(
        text: widget.state.netWeight,
        selection: TextSelection.collapsed(offset: widget.state.netWeight.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LabelInputField(
            label: '单箱数量',
            required: true,
            controller: _quantityController,
            placeholder: '请输入单箱数量',
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelInputField(
            label: '毛重(kg)',
            required: true,
            controller: _grossWeightController,
            placeholder: '请输入毛重',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelInputField(
            label: '净重(kg)',
            required: true,
            controller: _netWeightController,
            placeholder: '请输入净重',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
