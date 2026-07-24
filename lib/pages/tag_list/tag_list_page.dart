import 'package:flutter/material.dart';

import '../../entity/prod_tag.dart';
import '../../http/ProdTagApi.dart';
import '../../util/feedback_util.dart';
import '../home/components/custom_app_bar.dart';

class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  static const routeName = '/tagList';

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<ProdTag> _list = [];
  bool _loading = false;

  static String _fmtDate(DateTime d) =>
      '${d.year}/${_p(d.month)}/${_p(d.day)}';

  static String _fmtTime(DateTime d) =>
      '${_p(d.month)}-${_p(d.day)} ${_p(d.hour)}:${_p(d.minute)}';

  static String _fmtApi(DateTime d) =>
      '${d.year}-${_p(d.month)}-${_p(d.day)}';

  static String _p(int v) => v.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final start = _fmtApi(_startDate);
      final end = _fmtApi(_endDate);
      final result = await ProdTagApi.listByDate(start, end);
      setState(() => _list = result);
    } catch (e) {
      FeedbackUtil.showError('查询失败：${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _reset() {
    setState(() {
      _startDate = DateTime.now().subtract(const Duration(days: 7));
      _endDate = DateTime.now();
      _list = [];
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
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
        child: Column(
          children: [
            _buildFilterCard(),
            const SizedBox(height: 12),
            Expanded(child: _buildTableCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
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
          _buildDateField('开始日期', _startDate, () => _pickDate(true)),
          const SizedBox(width: 24),
          _buildDateField('结束日期', _endDate, () => _pickDate(false)),

          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loading ? null : _search,
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
            onPressed: _loading ? null : _reset,
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

  Widget _buildTableCard() {
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
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                    ? const Center(
                        child: Text('暂无数据',
                            style: TextStyle(
                                color: Color(0xFF7B8498), fontSize: 14)))
                    : ListView.separated(
                        itemCount: _list.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFEEF0F5)),
                        itemBuilder: (context, index) =>
                            _buildTableRow(_list[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    const style = TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF41495C));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _headerCell('打印时间', flex: 2, style: style),
          _headerCell('条码号', flex: 2, style: style),
          _headerCell('生产单号', flex: 2, style: style),
          _headerCell('客户编码', flex: 2, style: style),
          _headerCell('存货名称', flex: 3, style: style),
          _headerCell('规格型号', flex: 3, style: style),
          _headerCell('单数量', flex: 1, style: style),
          _headerCell('操作', flex: 2, style: style),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: style),
    );
  }

  Widget _buildTableRow(ProdTag tag) {
    const style = TextStyle(fontSize: 13, color: Color(0xFF22283A));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _dataCell(
              tag.createTime != null ? _fmtTime(tag.createTime!) : '-',
              flex: 2,
              style: style),
          _dataCell(tag.tagNo ?? '-', flex: 2, style: style),
          _dataCell(tag.prodNo ?? '-', flex: 2, style: style),
          _dataCell(tag.customerCode ?? '-', flex: 2, style: style),
          _dataCell(tag.inventoryName ?? '-', flex: 3, style: style),
          _dataCell(tag.spec ?? '-', flex: 3, style: style),
          _dataCell(tag.qty?.toString() ?? '-', flex: 1, style: style),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionButton('补打', const Color(0xFF3D63F0),
                    () => _handleReprint(tag)),
                const SizedBox(width: 8),
                _actionButton('作废', const Color(0xFFFF6B35),
                    () => _handleVoid(tag)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  void _handleReprint(ProdTag tag) {
    // TODO: 调用补打接口
    FeedbackUtil.showError('补打功能待实现');
  }

  void _handleVoid(ProdTag tag) {
    // TODO: 调用作废接口
    FeedbackUtil.showError('作废功能待实现');
  }
}
