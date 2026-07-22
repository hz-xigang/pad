import 'package:flutter/material.dart';

import '../../entity/production_order.dart';
import 'components/custom_app_bar.dart';
import 'components/label_action_buttons.dart';
import 'components/label_display_field.dart';
import 'components/label_input_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  // 可编辑字段 - 只有这4个需要手工输入
  final _productionNoController = TextEditingController();
  final _quantityController = TextEditingController();
  final _grossWeightController = TextEditingController();
  final _netWeightController = TextEditingController();

  // 从后端查询到的生产单信息（自动填充展示）
  ProductionOrder? _productionOrder;

  @override
  void dispose() {
    _productionNoController.dispose();
    _quantityController.dispose();
    _grossWeightController.dispose();
    _netWeightController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    // TODO: 调用后端API根据生产单号查询
    // 模拟查询后自动填充数据
    setState(() {
      _productionOrder = const ProductionOrder(
        erpOrderNo: 'UF202401001',
        customerCode: 'CUST001',
        inventoryCode: 'INV001',
        inventoryName: '产品名称示例',
        custMaterialNo: 'CUST-MAT-001',
        spec: '100x200x5mm',
        material: '不锈钢304',
        productCategory: '标准件',
      );
    });
  }

  void _handlePrint() {
    if (_formKey.currentState!.validate()) {
      // TODO: 调用打印接口
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开始打印标签')),
      );
    }
  }

  void _handleShowList() {
    // TODO: 跳转到标签列表页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看标签列表')),
    );
  }

  void _handleClear() {
    setState(() {
      _productionNoController.clear();
      _quantityController.clear();
      _grossWeightController.clear();
      _netWeightController.clear();
      _productionOrder = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EBF0),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: CustomAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3D63F0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '标签信息录入',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '输入生产单号自动带出相关信息',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildRow1(),
                const SizedBox(height: 16),
                _buildRow2(),
                const SizedBox(height: 16),
                _buildRow3(),
                const SizedBox(height: 16),
                _buildRow4(),
                const Spacer(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow1() {
    return Row(
      children: [
        Expanded(
          child: LabelInputField(
            label: '生产单号',
            required: true,
            controller: _productionNoController,
            placeholder: '请输入生产单号,回车查询...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF3D63F0)),
              onPressed: _handleSearch,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelDisplayField(
            label: '用友单号',
            value: _productionOrder?.erpOrderNo,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelDisplayField(
            label: '客户编码',
            value: _productionOrder?.customerCode,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelDisplayField(
            label: '存货编码',
            value: _productionOrder?.inventoryCode,
          ),
        ),
      ],
    );
  }

  Widget _buildRow2() {
    return Row(
      children: [
        Expanded(
          child: LabelDisplayField(
            label: '存货名称',
            value: _productionOrder?.inventoryName,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelDisplayField(
            label: '客户料号',
            value: _productionOrder?.custMaterialNo,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelDisplayField(
            label: '规格型号',
            value: _productionOrder?.spec,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LabelDisplayField(
            label: '产品材质',
            value: _productionOrder?.material,
          ),
        ),
      ],
    );
  }

  Widget _buildRow3() {
    return Row(
      children: [
        Expanded(
          child: LabelDisplayField(
            label: '产品类别',
            value: _productionOrder?.productCategory,
          ),
        ),
        const Expanded(flex: 3, child: SizedBox()),
      ],
    );
  }

  Widget _buildRow4() {
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

  Widget _buildActionButtons() {
    return LabelActionButtons(
      onPrint: _handlePrint,
      onShowList: _handleShowList,
      onClear: _handleClear,
    );
  }
}
