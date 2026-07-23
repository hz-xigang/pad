import 'package:flutter/foundation.dart';

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



    // TODO: 调用后端API根据生产单号查询
    // 模拟查询后自动填充数据
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
}
