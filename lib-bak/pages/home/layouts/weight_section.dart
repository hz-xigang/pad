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
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _grossWeightController.dispose();
    _netWeightController.dispose();
    super.dispose();
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
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelInputField(
            label: '毛重(kg)',
            required: true,
            controller: _grossWeightController,
            placeholder: '请输入毛重',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelInputField(
            label: '净重(kg)',
            required: true,
            controller: _netWeightController,
            placeholder: '请输入净重',
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
