import 'dart:convert';

import 'package:hive/hive.dart';

class ProductionOrder {
  const ProductionOrder({
    this.id,
    this.prodNo,
    this.erpOrderNo,
    this.inventoryCode,
    this.inventoryName,
    this.customerCode,
    this.productCategory,
    this.spec,
    this.status,
    this.deleted,
    this.createTime,
    this.m1,
    this.m2,
    this.m3,
    this.m4,
    this.m5,
    this.type,
    this.material,
    this.custMaterialNo
  });

  final String? id;
  final String? prodNo;
  final String? erpOrderNo;
  final String? inventoryCode;
  final String? inventoryName;
  final String? customerCode;
  final String? productCategory;
  final String? spec;
  final bool? status;
  final bool? deleted;
  final DateTime? createTime;
  final String? m1;
  final String? m2;
  final String? m3;
  final String? m4;
  final String? m5;
  final int? type;
  final String? material;
  final String? custMaterialNo;

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      id: _asString(json['id']),
      prodNo: _asString(json['prodNo']),
      erpOrderNo: _asString(json['erpOrderNo']),
      inventoryCode: _asString(json['inventoryCode']),
      inventoryName: _asString(json['inventoryName']),
      customerCode: _asString(json['customerCode']),
      productCategory: _asString(json['productCategory']),
      spec: _asString(json['spec']),
      status: _asBool(json['status']),
      deleted: _asBool(json['deleted']),
      createTime: _asDateTime(json['createTime']),
      m1: _asString(json['m1']),
      m2: _asString(json['m2']),
      m3: _asString(json['m3']),
      m4: _asString(json['m4']),
      m5: _asString(json['m5']),
      type: _asInt(json['type']),
      material: _asString(json['material']),
      custMaterialNo: _asString(json['custMaterialNo']),
    );
  }

  static ProductionOrder fromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    return ProductionOrder.fromJson(_asJsonMap(decoded));
  }

  static List<ProductionOrder> listFromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      throw const FormatException('JSON string is not a list.');
    }

    return decoded
        .map((item) => ProductionOrder.fromJson(_asJsonMap(item)))
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prodNo': prodNo,
      'erpOrderNo': erpOrderNo,
      'inventoryCode': inventoryCode,
      'inventoryName': inventoryName,
      'customerCode': customerCode,
      'productCategory': productCategory,
      'spec': spec,
      'status': status,
      'deleted': deleted,
      'createTime': createTime?.toIso8601String(),
      'm1': m1,
      'm2': m2,
      'm3': m3,
      'm4': m4,
      'm5': m5,
      'type': type,
      'material': material,
      'custMaterialNo': custMaterialNo,
    };
  }

  static Map<String, dynamic> _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    throw const FormatException('JSON value is not an object.');
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static int? _asInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static bool? _asBool(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final String normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
    return null;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'ProductionOrder{id: $id, prodNo: $prodNo, erpOrderNo: $erpOrderNo, inventoryCode: $inventoryCode, inventoryName: $inventoryName, customerCode: $customerCode, productCategory: $productCategory, spec: $spec, status: $status, deleted: $deleted, createTime: $createTime, m1: $m1, m2: $m2, m3: $m3, m4: $m4, m5: $m5, type: $type}';
  }


}

class ProductionOrderAdapter extends TypeAdapter<ProductionOrder> {
  @override
  final int typeId = 1;

  @override
  ProductionOrder read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return ProductionOrder(
      id: fields[0] as String?,
      prodNo: fields[1] as String?,
      erpOrderNo: fields[2] as String?,
      inventoryCode: fields[3] as String?,
      inventoryName: fields[4] as String?,
      customerCode: fields[5] as String?,
      productCategory: fields[6] as String?,
      spec: fields[7] as String?,
      status: fields[8] as bool?,
      deleted: fields[9] as bool?,
      createTime: fields[10] as DateTime?,
      m1: fields[11] as String?,
      m2: fields[12] as String?,
      m3: fields[13] as String?,
      m4: fields[14] as String?,
      m5: fields[15] as String?,
      type: fields[16] as int?,
      material: fields[17] as String?,
      custMaterialNo: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionOrder obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prodNo)
      ..writeByte(2)
      ..write(obj.erpOrderNo)
      ..writeByte(3)
      ..write(obj.inventoryCode)
      ..writeByte(4)
      ..write(obj.inventoryName)
      ..writeByte(5)
      ..write(obj.customerCode)
      ..writeByte(6)
      ..write(obj.productCategory)
      ..writeByte(7)
      ..write(obj.spec)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.deleted)
      ..writeByte(10)
      ..write(obj.createTime)
      ..writeByte(11)
      ..write(obj.m1)
      ..writeByte(12)
      ..write(obj.m2)
      ..writeByte(13)
      ..write(obj.m3)
      ..writeByte(14)
      ..write(obj.m4)
      ..writeByte(15)
      ..write(obj.m5)
      ..writeByte(16)
      ..write(obj.type)
      ..writeByte(18)
      ..write(obj.material)
      ..writeByte(19)
      ..write(obj.custMaterialNo);
  }
}
