import 'package:flutter/material.dart';
import 'package:hz_xg_pad/http/ProdTagApi.dart';

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

    try {
      final req = {
        "startDate": _fmtApi(_startDate),
        "endDate": _fmtApi(_endDate),
        "prodNo": _prodNo,
        "customerCode": _customerCode,
        "inventoryName": _inventoryName,
      };

      final result = await ProdTagApi.list(req);
      _list = result;
    } catch (e) {
      FeedbackUtil.showError('查询失败：${e.toString()}');
      _list = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void reset() {
    _prodNo = '';
    _customerCode = '';
    _inventoryName = '';
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();
    _list = [];
    notifyListeners();
    search();
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
