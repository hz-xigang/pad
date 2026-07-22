import 'package:flutter/material.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  // 可编辑字段
  final _productionNoController = TextEditingController();
  final _quantityController = TextEditingController();
  final _grossWeightController = TextEditingController();
  final _netWeightController = TextEditingController();

  // 自动填充字段
  final _ufOrderNoController = TextEditingController();
  final _customerCodeController = TextEditingController();
  final _inventoryCodeController = TextEditingController();
  final _inventoryNameController = TextEditingController();
  final _customerPartNoController = TextEditingController();
  final _specModelController = TextEditingController();
  final _productMaterialController = TextEditingController();
  final _productCategoryController = TextEditingController();

  @override
  void dispose() {
    _productionNoController.dispose();
    _quantityController.dispose();
    _grossWeightController.dispose();
    _netWeightController.dispose();
    _ufOrderNoController.dispose();
    _customerCodeController.dispose();
    _inventoryCodeController.dispose();
    _inventoryNameController.dispose();
    _customerPartNoController.dispose();
    _specModelController.dispose();
    _productMaterialController.dispose();
    _productCategoryController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    // 模拟查询后自动填充
    setState(() {
      _ufOrderNoController.text = '自动填充';
      _customerCodeController.text = '自动填充';
      _inventoryCodeController.text = '自动填充';
      _inventoryNameController.text = '自动填充';
      _customerPartNoController.text = '自动填充';
      _specModelController.text = '自动填充';
      _productMaterialController.text = '自动填充';
      _productCategoryController.text = '自动填充';
    });
  }

  void _handlePrint() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开始打印标签')),
      );
    }
  }

  void _handleShowList() {
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
      _ufOrderNoController.clear();
      _customerCodeController.clear();
      _inventoryCodeController.clear();
      _inventoryNameController.clear();
      _customerPartNoController.clear();
      _specModelController.clear();
      _productMaterialController.clear();
      _productCategoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EBF0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _CustomAppBar(),
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
          child: _buildTextField(
            label: '生产单号',
            required: true,
            controller: _productionNoController,
            placeholder: '请输入生产单号，回车查询...',
            autoFill: false,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF3D63F0)),
              onPressed: _handleSearch,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '用友单号',
            controller: _ufOrderNoController,
            autoFill: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '客户编码',
            controller: _customerCodeController,
            autoFill: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '存货编码',
            controller: _inventoryCodeController,
            autoFill: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRow2() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            label: '存货名称',
            controller: _inventoryNameController,
            autoFill: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '客户料号',
            controller: _customerPartNoController,
            autoFill: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '规格型号',
            controller: _specModelController,
            autoFill: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '产品材质',
            controller: _productMaterialController,
            autoFill: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRow3() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            label: '产品类别',
            controller: _productCategoryController,
            autoFill: true,
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
          child: _buildTextField(
            label: '单箱数量',
            required: true,
            controller: _quantityController,
            placeholder: '请输入单箱数量',
            autoFill: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '毛重(kg)',
            required: true,
            controller: _grossWeightController,
            placeholder: '请输入毛重',
            autoFill: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            label: '净重(kg)',
            required: true,
            controller: _netWeightController,
            placeholder: '请输入净重',
            autoFill: false,
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    bool required = false,
    required TextEditingController controller,
    String? placeholder,
    bool autoFill = false,
    Widget? suffixIcon,
  }) {
    final labelColor = required ? const Color(0xFFFF6B00) : Colors.black;
    final autoFillColor = autoFill ? const Color(0xFF3D63F0) : Colors.grey[600];

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
            const SizedBox(width: 8),
            if (autoFill)
              Text(
                '自动带出',
                style: TextStyle(
                  fontSize: 12,
                  color: autoFillColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !autoFill,
          decoration: InputDecoration(
            hintText: placeholder ?? '自动填充',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: autoFill ? const Color(0xFFF5F7FA) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF3D63F0)),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _handlePrint,
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
          onPressed: _handleShowList,
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
          onPressed: _handleClear,
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

class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C3E50),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D63F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.label,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '标签打印管理系统',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    '当前账号：',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.content_paste, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    child: const Row(
                      children: [
                        Text(
                          '管理员',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                    onSelected: (value) {
                      if (value == 'logout') {
                        Navigator.pushReplacementNamed(
                          context,
                          LoginPage.routeName,
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('退出登录'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
