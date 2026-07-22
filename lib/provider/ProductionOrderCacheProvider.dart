import 'package:hive/hive.dart';
import '../entity/production_order.dart';


class ProductionOrderCacheProvider {
  ProductionOrderCacheProvider._();

  static const String boxName = 'carton_print_box';
  static const String productionOrderKey = 'cached_production_order';

  static Future<Box<dynamic>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return Hive.openBox<dynamic>(boxName);
  }

  static Future<void> saveProductionOrder(ProductionOrder? productionOrder) async {
    final box = await _getBox();

    if (productionOrder == null) {
      await box.delete(productionOrderKey);
      return;
    }

    await box.put(
      productionOrderKey,
      productionOrder,
    );
  }

  static Future<ProductionOrder?> getProductionOrder() async {
    final box = await _getBox();
    final dynamic raw = box.get(productionOrderKey);

    if (raw is ProductionOrder) {
      return raw;
    }
    return null;
  }

  static Future<void> clearProductionOrder() async {
    final box = await _getBox();
    await box.delete(productionOrderKey);
  }
}
