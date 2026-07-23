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

  // 焦点恢复回调（在清空表单后调用）
  VoidCallback? _onNeedFocusCallback;

  ProductionOrder? get productionOrder => _productionOrder;
  String get productionNo => _productionNo;
  String get quantity => _quantity;
  String get grossWeight => _grossWeight;
  String get netWeight => _netWeight;

  // 设置焦点恢复回调
  void setOnNeedFocusCallback(VoidCallback callback) {
    _onNeedFocusCallback = callback;
  }

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

    try {
      _productionOrder = await ProdApi.findByPgNo(_productionNo);
      notifyListeners();
      // 查询完成后恢复焦点
      _onNeedFocusCallback?.call();
    } catch (e) {
      FeedbackUtil.showError('查询失败：${e.toString()}');
      _productionOrder = null;
      notifyListeners();
    }
  }

  // 清空表单
  void clearForm() {
    _productionNo = '';
    _quantity = '';
    _grossWeight = '';
    _netWeight = '';
    _productionOrder = null;
    notifyListeners();
    // 清空后恢复焦点
    _onNeedFocusCallback?.call();
  }

  // 验证表单
  bool validate() {
    return _productionNo.isNotEmpty &&
        _quantity.isNotEmpty &&
        _grossWeight.isNotEmpty &&
        _netWeight.isNotEmpty;
  }

  // 验证输入数值的有效性
  bool inputValid() {
    if (_quantity.isEmpty || _grossWeight.isEmpty || _netWeight.isEmpty) {
      return false;
    }

    final quantity = int.tryParse(_quantity.trim());
    final grossWeight = double.tryParse(_grossWeight.trim());
    final netWeight = double.tryParse(_netWeight.trim());

    if (quantity == null || quantity <= 0) {
      FeedbackUtil.showError("单箱数量必须是大于0的整数");
      return false;
    }

    if (grossWeight == null || grossWeight <= 0) {
      FeedbackUtil.showError("毛重必须是大于0的数字");
      return false;
    }

    if (netWeight == null || netWeight <= 0) {
      FeedbackUtil.showError("净重必须是大于0的数字");
      return false;
    }

    if (netWeight >= grossWeight) {
      FeedbackUtil.showError("净重必须小于毛重");
      return false;
    }

    return true;
  }
}
