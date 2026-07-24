import 'package:flutter/material.dart';

import '../../../entity/prod_tag.dart';
import '../../../util/feedback_util.dart';



class TagListState extends ChangeNotifier {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _prodNo = '';
  String _customerCode = '';
  String _inventoryName = '';
  List<ProdTag> _list = [];
  bool _loading = false;

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get prodNo => _prodNo;
  String get customerCode => _customerCode;
  String get inventoryName => _inventoryName;
  List<ProdTag> get list => _list;
  bool get loading => _loading;

  static String _p(int v) => v.toString().padLeft(2, '0');

  static String _fmtApi(DateTime d) =>
      '${d.year}-${_p(d.month)}-${_p(d.day)}';

  void setStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void setProdNo(String value) {
    _prodNo = value;
  }

  void setCustomerCode(String value) {
    _customerCode = value;
  }

  void setInventoryName(String value) {
    _inventoryName = value;
  }

  Future<void> search() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _list = _mockData();
    _loading = false;
    notifyListeners();
  }

  void reset() {
    _prodNo = '';
    _customerCode = '';
    _inventoryName = '';
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();
    _list = [];
    notifyListeners();
  }

  List<ProdTag> _mockData() {
    final now = DateTime.now();
    return [
      ProdTag(
        id: '2026072316542771552796281',
        tagNo: '1260723000227',
        prodNo: 'PO20260723001',
        customerCode: 'CUST001',
        inventoryName: '螺旋桨组件A',
        spec: '200×150×80mm',
        qty: 12,
        grossWeight: 5.6,
        netWeight: 4.8,
        createTime: now.subtract(const Duration(hours: 2)),
      ),
      ProdTag(
        id: '2026072316542771552796282',
        tagNo: '1260723000228',
        prodNo: 'PO20260723001',
        customerCode: 'CUST001',
        inventoryName: '螺旋桨组件A',
        spec: '200×150×80mm',
        qty: 12,
        grossWeight: 5.6,
        netWeight: 4.8,
        createTime: now.subtract(const Duration(hours: 3)),
      ),
      ProdTag(
        id: '2026072316542771552796283',
        tagNo: '1260722000115',
        prodNo: 'PO20260722008',
        customerCode: 'CUST002',
        inventoryName: '传动轴总成',
        spec: '标准型 L=600',
        qty: 6,
        grossWeight: 12.3,
        netWeight: 11.0,
        createTime: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      ProdTag(
        id: '2026072316542771552796284',
        tagNo: '1260721000088',
        prodNo: 'PO20260721003',
        customerCode: 'CUST003',
        inventoryName: '减速箱壳体',
        spec: 'HB-300',
        qty: 4,
        grossWeight: 18.5,
        netWeight: 17.2,
        createTime: now.subtract(const Duration(days: 2, hours: 5)),
      ),
      ProdTag(
        id: '2026072316542771552796285',
        tagNo: '1260720000050',
        prodNo: 'PO20260720005',
        customerCode: 'CUST001',
        inventoryName: '不锈钢法兰盘',
        spec: 'DN50-PN16',
        qty: 20,
        grossWeight: 8.0,
        netWeight: 7.2,
        createTime: now.subtract(const Duration(days: 3)),
        deleted: 1,
      ),
    ];
  }

  List<ProdTag> tableData = [];
  void initTableData() async{
    var req = {
      "startDate" : _startDate,
      "endDate" : _endDate,
      "prodNo" : _prodNo,
      "customerCode" : customerCode,
      "inventoryName" : inventoryName
    };

    print(req);
  }


  void handleReprint(ProdTag tag) {
    // TODO: 调用补打接口
    FeedbackUtil.showError('补打功能待实现');
  }

  void handleVoid(ProdTag tag) {
    // TODO: 调用作废接口
    FeedbackUtil.showError('作废功能待实现');
  }
}
