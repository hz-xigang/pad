import 'dart:convert';

import 'package:hive/hive.dart';

class ProdTag {
  const ProdTag({
    this.id,
    this.tagNo,
    this.prodOrderId,
    this.grossWeight,
    this.netWeight,
    this.printUser,
    this.productCategory,
    this.qty,
    this.prodNo,
    this.createTime,
    this.spec,
    this.customerCode,
    this.inventoryCode,
    this.locId,
    this.locCode,
  });

  final String? id;
  final String? tagNo;
  final String? prodOrderId;
  final double? grossWeight;
  final double? netWeight;
  final String? printUser;
  final String? productCategory;
  final double? qty;
  final String? prodNo;
  final DateTime? createTime;
  final String? spec;
  final String? customerCode;
  final String? inventoryCode;
  final String? locId;
  final String? locCode;

  factory ProdTag.fromJson(Map<String, dynamic> json) {
    return ProdTag(
      id: _asString(json['id']),
      tagNo: _asString(json['tagNo']),
      prodOrderId: _asString(json['prodOrderId']),
      grossWeight: _asDouble(json['grossWeight']),
      netWeight: _asDouble(json['netWeight']),
      printUser: _asString(json['printUser']),
      productCategory: _asString(json['productCategory']),
      qty: _asDouble(json['qty']),
      prodNo: _asString(json['prodNo']),
      createTime: _asDateTime(json['createTime']),
      spec: _asString(json['spec']),
      customerCode: _asString(json['customerCode']),
      inventoryCode: _asString(json['inventoryCode']),
      locId: _asString(json['locId']),
      locCode: _asString(json['locCode']),
    );
  }

  static ProdTag fromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    return ProdTag.fromJson(_asJsonMap(decoded));
  }

  static List<ProdTag> listFromJsonString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    return listFromDynamic(decoded);
  }

  static List<ProdTag> listFromDynamic(dynamic value) {
    if (value is! List) {
      throw const FormatException('JSON value is not a list.');
    }

    return value
        .map((item) => ProdTag.fromJson(_asJsonMap(item)))
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagNo': tagNo,
      'prodOrderId': prodOrderId,
      'grossWeight': grossWeight,
      'netWeight': netWeight,
      'printUser': printUser,
      'productCategory': productCategory,
      'qty': qty,
      'prodNo': prodNo,
      'createTime': createTime?.toIso8601String(),
      'spec': spec,
      'customerCode': customerCode,
      'inventoryCode': inventoryCode,
      'locId': locId,
      'locCode': locCode,
    };
  }

  static Map<String, dynamic> _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    throw const FormatException('JSON value is not an object.');
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
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
}

class ProdTagAdapter extends TypeAdapter<ProdTag> {
  @override
  final int typeId = 2;

  @override
  ProdTag read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return ProdTag(
      id: fields[0] as String?,
      tagNo: fields[1] as String?,
      prodOrderId: fields[2] as String?,
      grossWeight: fields[3] as double?,
      netWeight: fields[4] as double?,
      printUser: fields[5] as String?,
      productCategory: fields[6] as String?,
      qty: fields[7] as double?,
      prodNo: fields[8] as String?,
      createTime: fields[9] as DateTime?,
      spec: fields[10] as String?,
      customerCode: fields[11] as String?,
      inventoryCode: fields[12] as String?,
      locId: fields[13] as String?,
      locCode: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProdTag obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tagNo)
      ..writeByte(2)
      ..write(obj.prodOrderId)
      ..writeByte(3)
      ..write(obj.grossWeight)
      ..writeByte(4)
      ..write(obj.netWeight)
      ..writeByte(5)
      ..write(obj.printUser)
      ..writeByte(6)
      ..write(obj.productCategory)
      ..writeByte(7)
      ..write(obj.qty)
      ..writeByte(8)
      ..write(obj.prodNo)
      ..writeByte(9)
      ..write(obj.createTime)
      ..writeByte(10)
      ..write(obj.spec)
      ..writeByte(11)
      ..write(obj.customerCode)
      ..writeByte(12)
      ..write(obj.inventoryCode)
        ..writeByte(13)
      ..write(obj.locId)
      ..writeByte(14)
      ..write(obj.locCode);
  }
}
