import 'package:flutter/material.dart';

import '../state/tag_list_state.dart';

class TagFilterSection extends StatefulWidget {
  final TagListState state;
  final VoidCallback onBack;

  const TagFilterSection({
    super.key,
    required this.state,
    required this.onBack,
  });

  @override
  State<TagFilterSection> createState() => _TagFilterSectionState();
}

class _TagFilterSectionState extends State<TagFilterSection> {
  late final TextEditingController _prodNoController;
  late final TextEditingController _customerCodeController;
  late final TextEditingController _inventoryNameController;

  @override
  void initState() {
    super.initState();
    _prodNoController = TextEditingController(text: widget.state.prodNo);
    _customerCodeController = TextEditingController(text: widget.state.customerCode);
    _inventoryNameController = TextEditingController(text: widget.state.inventoryName);

    _prodNoController.addListener(() {
      widget.state.setProdNo(_prodNoController.text);
    });
    _customerCodeController.addListener(() {
      widget.state.setCustomerCode(_customerCodeController.text);
    });
    _inventoryNameController.addListener(() {
      widget.state.setInventoryName(_inventoryNameController.text);
    });
  }

  @override
  void dispose() {
    _prodNoController.dispose();
    _customerCodeController.dispose();
    _inventoryNameController.dispose();
    super.dispose();
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}/${_p(d.month)}/${_p(d.day)}';

  static String _p(int v) => v.toString().padLeft(2, '0');

  void _handleReset() {
    widget.state.reset();
    _prodNoController.clear();
    _customerCodeController.clear();
    _inventoryNameController.clear();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? widget.state.startDate : widget.state.endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked == null) return;
    if (isStart) {
      widget.state.setStartDate(picked);
    } else {
      widget.state.setEndDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF41495C)),
                  SizedBox(width: 4),
                  Text('返回', style: TextStyle(fontSize: 14, color: Color(0xFF41495C))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          _buildDateField('开始日期', widget.state.startDate, () => _pickDate(true)),
          const SizedBox(width: 16),
          _buildDateField('结束日期', widget.state.endDate, () => _pickDate(false)),
          const SizedBox(width: 16),
          _buildTextField('生产单号', _prodNoController),
          const SizedBox(width: 16),
          _buildTextField('客户编码', _customerCodeController),
          const SizedBox(width: 16),
          _buildTextField('存货名称', _inventoryNameController),

          const Spacer(),
          ElevatedButton.icon(
            onPressed: widget.state.loading ? null : widget.state.search,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('搜索'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D63F0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: widget.state.loading ? null : _handleReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('重置'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3D63F0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Color(0xFF3D63F0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF41495C),
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Text(
                  _fmtDate(date),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF22283A)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today,
                    size: 16, color: Color(0xFF7B8498)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF41495C),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFADB5BD)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFF3D63F0)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF22283A)),
          ),
        ],
      ),
    );
  }
}
