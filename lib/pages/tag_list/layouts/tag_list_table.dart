import 'package:flutter/material.dart';

import '../../../entity/prod_tag.dart';
import '../state/tag_list_state.dart';

class TagListTable extends StatelessWidget {
  final TagListState state;

  const TagListTable({
    super.key,
    required this.state,
  });

  static String _fmtTime(DateTime d) =>
      '${_p(d.month)}-${_p(d.day)} ${_p(d.hour)}:${_p(d.minute)}';

  static String _p(int v) => v.toString().padLeft(2, '0');

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
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.list.isEmpty
                    ? const Center(
                        child: Text('暂无数据',
                            style: TextStyle(
                                color: Color(0xFF7B8498), fontSize: 14)))
                    : ListView.separated(
                        itemCount: state.list.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFEEF0F5)),
                        itemBuilder: (context, index) =>
                            _buildTableRow(state.list[index]),
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
    final isVoided = (tag.deleted ?? 0) != 0;
    final textStyle = TextStyle(
      fontSize: 13,
      color: isVoided ? const Color(0xFFADB5BD) : const Color(0xFF22283A),
      decoration: isVoided ? TextDecoration.lineThrough : null,
      decorationColor: const Color(0xFFADB5BD),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _dataCell(
              tag.createTime != null ? _fmtTime(tag.createTime!) : '-',
              flex: 2,
              style: textStyle),
          _dataCell(tag.tagNo ?? '-', flex: 2, style: textStyle),
          _dataCell(tag.prodNo ?? '-', flex: 2, style: textStyle),
          _dataCell(tag.customerCode ?? '-', flex: 2, style: textStyle),
          _dataCell(tag.inventoryName ?? '-', flex: 3, style: textStyle),
          _dataCell(tag.spec ?? '-', flex: 3, style: textStyle),
          _dataCell(tag.qty?.toString() ?? '-', flex: 1, style: textStyle),

          Expanded(
            flex: 2,
            child: isVoided
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEE8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已作废',
                      style: TextStyle(color: Color(0xFFFF6B35), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  )
                : Row(
                    children: [
                      _actionButton('补打', const Color(0xFF3D63F0),
                          () => state.handleReprint(tag)),
                      const SizedBox(width: 8),
                      _actionButton('作废', const Color(0xFFFF6B35),
                          () => state.handleVoid(tag)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}
