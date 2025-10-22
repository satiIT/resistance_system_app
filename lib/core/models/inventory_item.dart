// models/inventory_item.dart
import 'package:flutter/material.dart';

class InventoryItem {
  final int? id;
  final int? itemId;
  final int? fromStore;
  final int? toStore;
  final String movementType; // 'وارد' أو 'منصرف'
  final double quantity;
  final DateTime movementDate;
  final String? approvedBy;
  final String? notes;
  final String? packaging;
  final DateTime? expiryDate;
  final String? supplierEntity;
  final String? receiverEntity;
  final String? packagingDetails;
  final String? batchNumber;
  
  // حقول مرتبطة (من JOIN)
  final String? itemName;
  final String? itemCode;
  final String? category;
  final String? unitOfMeasure;
  final String? fromStoreName;
  final String? toStoreName;

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

  // من JSON إلى كائن
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      itemId: json['item_id'],
      fromStore: json['from_store'],
      toStore: json['to_store'],
      movementType: json['movement_type'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      movementDate: DateTime.parse(json['movement_date'] ?? DateTime.now().toString()),
      approvedBy: json['approved_by'],
      notes: json['notes'],
      packaging: json['packaging'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      supplierEntity: json['supplier_entity'],
      receiverEntity: json['receiver_entity'],
      packagingDetails: json['packaging_details'],
      batchNumber: json['batch_number'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      category: json['category'],
      unitOfMeasure: json['unit_of_measure'],
      fromStoreName: json['from_store_name'],
      toStoreName: json['to_store_name'],
    );
  }

  // من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
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

  // دوال مساعدة
  String get description => movementType;
  String get entity => movementType == 'وارد' ? (supplierEntity ?? '') : (receiverEntity ?? '');
  
  Color get typeColor => movementType == 'وارد' ? Colors.green : Colors.orange;
  IconData get typeIcon => movementType == 'وارد' ? Icons.input : Icons.output;
  
  bool get isLowStock => false; // سيتم حسابه من الخادم
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  
  String get expiryStatus {
    if (expiryDate == null) return 'غير محدد';
    final now = DateTime.now();
    final difference = expiryDate!.difference(now).inDays;
    
    if (difference < 0) return 'منتهي';
    if (difference <= 30) return 'قريب الانتهاء';
    return 'ساري';
  }
  
  Color get expiryColor {
    if (expiryDate == null) return Colors.grey;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now).inDays;
    
    if (difference < 0) return Colors.red;
    if (difference <= 30) return Colors.orange;
    return Colors.green;
  }
}