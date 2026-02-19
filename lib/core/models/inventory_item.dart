import 'package:flutter/material.dart';

class InventoryItem {
  int? id;
  int? itemId; // معرف الصنف
  int? fromStore; // معرف المخزن المصدر
  int? toStore; // معرف المخزن الوجهة
  String movementType; // نوع الحركة (وارد/منصرف/نقل)
  double quantity; // الكمية
  DateTime movementDate; // تاريخ الحركة
  String? approvedBy; // المعتمد
  String? notes; // ملاحظات
  String? packaging; // نوع العبوة
  DateTime? expiryDate; // تاريخ الانتهاء
  String? supplierEntity; // الجهة الموردة
  String? receiverEntity; // الجهة المستلمة
  String? packagingDetails; // تفاصيل العبوة
  String? batchNumber; // رقم الدفعة

  // حقول إضافية من JOIN
  String? itemName; // اسم الصنف
  String? itemCode; // كود الصنف
  String? category; // التصنيف
  String? unitOfMeasure; // وحدة القياس
  String? fromStoreName; // اسم المخزن المصدر
  String? toStoreName; // اسم المخزن الوجهة

  // قائمة الأصناف الثابتة للتعويض في حالة وجود مشكلة في الترميز
  static final Map<int, Map<String, String>> staticItems = {
    1: {'name': 'دقيق', 'code': 'FLO001', 'category': 'مواد غذائية'},
    2: {'name': 'سكر', 'code': 'SUG001', 'category': 'مواد غذائية'},
    3: {'name': 'زيت', 'code': 'OIL001', 'category': 'مواد غذائية'},
    4: {'name': 'بصل', 'code': 'ONI001', 'category': 'خضروات'},
    5: {'name': 'أرز', 'code': 'RIC001', 'category': 'مواد غذائية'},
    6: {'name': 'شاي', 'code': 'TEA001', 'category': 'مشروبات'},
    7: {'name': 'قهوة', 'code': 'COF001', 'category': 'مشروبات'},
    8: {'name': 'معكرونة', 'code': 'PAS001', 'category': 'مواد غذائية'},
    9: {'name': 'لبن', 'code': 'MIL001', 'category': 'ألبان'},
    10: {'name': 'جبن', 'code': 'CHS001', 'category': 'ألبان'},
    11: {'name': 'لحم', 'code': 'MEA001', 'category': 'لحوم'},
    12: {'name': 'دجاج', 'code': 'CHI001', 'category': 'لحوم'},
    13: {'name': 'سمك', 'code': 'FIS001', 'category': 'لحوم'},
    14: {'name': 'خضار', 'code': 'VEG001', 'category': 'خضروات'},
    15: {'name': 'فواكه', 'code': 'FRU001', 'category': 'فواكه'},
    16: {'name': 'مواد تنظيف', 'code': 'CLE001', 'category': 'منظفات'},
    17: {'name': 'أدوية', 'code': 'MED001', 'category': 'طبية'},
  };

  InventoryItem({
    this.id,
    this.itemId,
    this.fromStore,
    this.toStore,
    required this.movementType,
    required this.quantity,
    required this.movementDate,
    this.approvedBy,
    this.notes,
    this.packaging,
    this.expiryDate,
    this.supplierEntity,
    this.receiverEntity,
    this.packagingDetails,
    this.batchNumber,
    this.itemName,
    this.itemCode,
    this.category,
    this.unitOfMeasure,
    this.fromStoreName,
    this.toStoreName,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      itemId: json['item_id'],
      fromStore: json['from_store'],
      toStore: json['to_store'],
      movementType: _safeString(json['movement_type'], 'وارد'),
      quantity: (json['quantity'] ?? 0).toDouble(),
      movementDate: json['movement_date'] != null
          ? DateTime.parse(json['movement_date'])
          : DateTime.now(),
      approvedBy: _safeString(json['approved_by']),
      notes: _safeString(json['notes']),
      packaging: _safeString(json['packaging']),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      supplierEntity: _safeString(json['supplier_entity']),
      receiverEntity: _safeString(json['receiver_entity']),
      packagingDetails: _safeString(json['packaging_details']),
      batchNumber: _safeString(json['batch_number']),
      itemName: _resolveName(
        json['item_id'],
        json['item_name'],
      ), // استخدام دالة ذكية للاسم
      itemCode: _resolveCode(json['item_id'], json['item_code']),
      category: _resolveCategory(json['item_id'], json['category']),
      unitOfMeasure: _safeString(json['unit_of_measure']),
      fromStoreName: _safeString(json['from_store_name']),
      toStoreName: _safeString(json['to_store_name']),
    );
  }

  static String _safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) {
      if (value.isEmpty ||
          value.toLowerCase() == 'null' ||
          value.toLowerCase() == 'undefined') {
        return defaultValue;
      }
      return value;
    }
    return value.toString();
  }

  // دوال مساعدة لحل مشاكل البيانات المفقودة أو التالفة
  static String _resolveName(dynamic id, dynamic name) {
    String safeName = _safeString(name);
    // إذا كان الاسم تالفاً (علامات استفهام) أو فارغاً، نحاول استرجاعه من القائمة الثابتة
    if (safeName.isEmpty || safeName.contains('?') || safeName.contains('؟')) {
      int? itemId = id is int ? id : int.tryParse(id.toString());
      if (itemId != null && staticItems.containsKey(itemId)) {
        return staticItems[itemId]!['name']!;
      }
    }
    return safeName.isEmpty && id != null ? 'صنف #$id' : safeName;
  }

  static String _resolveCode(dynamic id, dynamic code) {
    String safeCode = _safeString(code);
    if (safeCode.isEmpty) {
      int? itemId = id is int ? id : int.tryParse(id.toString());
      if (itemId != null && staticItems.containsKey(itemId)) {
        return staticItems[itemId]!['code']!;
      }
    }
    return safeCode;
  }

  static String _resolveCategory(dynamic id, dynamic category) {
    String safeCategory = _safeString(category);
    if (safeCategory.isEmpty ||
        safeCategory.contains('?') ||
        safeCategory.contains('؟')) {
      int? itemId = id is int ? id : int.tryParse(id.toString());
      if (itemId != null && staticItems.containsKey(itemId)) {
        return staticItems[itemId]!['category']!;
      }
    }
    return safeCategory;
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'from_store': fromStore,
      'to_store': toStore,
      'movement_type': movementType,
      'quantity': quantity,
      'movement_date': movementDate.toIso8601String().split('T')[0],
      'approved_by': approvedBy,
      'notes': notes,
      'packaging': packaging,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'supplier_entity': supplierEntity,
      'receiver_entity': receiverEntity,
      'packaging_details': packagingDetails,
      'batch_number': batchNumber,
    };
  }

  InventoryItem copyWith({
    int? id,
    int? itemId,
    int? fromStore,
    int? toStore,
    String? movementType,
    double? quantity,
    DateTime? movementDate,
    String? approvedBy,
    String? notes,
    String? packaging,
    DateTime? expiryDate,
    String? supplierEntity,
    String? receiverEntity,
    String? packagingDetails,
    String? batchNumber,
    String? itemName,
    String? itemCode,
    String? category,
    String? unitOfMeasure,
    String? fromStoreName,
    String? toStoreName,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      fromStore: fromStore ?? this.fromStore,
      toStore: toStore ?? this.toStore,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      movementDate: movementDate ?? this.movementDate,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
      packaging: packaging ?? this.packaging,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierEntity: supplierEntity ?? this.supplierEntity,
      receiverEntity: receiverEntity ?? this.receiverEntity,
      packagingDetails: packagingDetails ?? this.packagingDetails,
      batchNumber: batchNumber ?? this.batchNumber,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      fromStoreName: fromStoreName ?? this.fromStoreName,
      toStoreName: toStoreName ?? this.toStoreName,
    );
  }

  String get type => movementType;

  Color get typeColor {
    switch (movementType) {
      case 'وارد':
        return Colors.green;
      case 'منصرف':
        return Colors.red;
      case 'نقل':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (movementType) {
      case 'وارد':
        return Icons.arrow_downward;
      case 'منصرف':
        return Icons.arrow_upward;
      case 'نقل':
        return Icons.swap_horiz;
      default:
        return Icons.help;
    }
  }

  String get entity =>
      movementType == 'وارد' ? supplierEntity ?? '' : receiverEntity ?? '';

  String get description => notes ?? '';

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  String get expiryStatus {
    if (expiryDate == null) return 'غير محدد';
    if (isExpired) return 'منتهي الصلاحية';

    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 30) return 'ينتهي قريباً';
    return 'ساري';
  }

  Color get expiryColor {
    if (expiryDate == null) return Colors.grey;
    if (isExpired) return Colors.red;

    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 30) return Colors.orange;
    return Colors.green;
  }
}
