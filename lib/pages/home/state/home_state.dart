import 'package:flutter/foundation.dart';
import 'package:hz_xg_pad/http/ProdApi.dart';
import 'package:hz_xg_pad/util/feedback_util.dart';

import '../../../entity/production_order.dart';

class HomeState extends ChangeNotifier {
  // 生产单信息（从后端查询）
  ProductionOrder? _productionOrder;

  // 手工输入的数据
  String _productionNo = '';
  String _quantity = '';
  String _grossWeight = '';
  String _netWeight = '';

  ProductionOrder? get productionOrder => _productionOrder;
  String get productionNo => _productionNo;
  String get quantity => _quantity;
  String get grossWeight => _grossWeight;
  String get netWeight => _netWeight;

  void setProductionNo(String value) {
    _productionNo = value;
    notifyListeners();
  }

  void setQuantity(String value) {
    _quantity = value;
    notifyListeners();
  }

  void setGrossWeight(String value) {
    _grossWeight = value;
    notifyListeners();
  }

  void setNetWeight(String value) {
    _netWeight = value;
    notifyListeners();
  }

  // 查询生产单信息
  Future<void> searchProductionOrder() async {
    if (_productionNo.isEmpty) {
      return;
    }
     _productionOrder = await ProdApi.findByPgNo(_productionNo);
    notifyListeners();
  }

  // 清空表单
  void clearForm() {
    _productionNo = '';
    _quantity = '';
    _grossWeight = '';
    _netWeight = '';
    _productionOrder = null;
    notifyListeners();
  }

  // 验证表单
  bool validate() {
    return _productionNo.isNotEmpty &&
        _quantity.isNotEmpty &&
        _grossWeight.isNotEmpty &&
        _netWeight.isNotEmpty;
  }

  bool inputValid() {
    if (_isPositiveInt(_quantity)) {
      FeedbackUtil.showError("数量不能为0");
      return false;
    }
    if (_isPositiveInt(_grossWeight)) {
      FeedbackUtil.showError("毛重不能为0");
      return false;
    }
    if (_isPositiveInt(_netWeight)) {
      FeedbackUtil.showError("净重不能为0");
      return false;
    }
    return true;
  }

  bool _isPositiveInt(String value) {
    final int? parsed = int.tryParse(value.trim());
    return parsed != null && parsed > 0;
  }

}
