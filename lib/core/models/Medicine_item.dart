// core/models/medicine_item.dart - التصحيح
import 'package:flutter/material.dart';

class MedicineItem {
  final int? id;
  final DateTime movementDate;
  final String movementType; // 'وارد' أو 'منصرف'
  final int? itemId;
  final int? storeId;
  final String? sourceOrRecipient;
  final String? medicineType;
  final String? packaging;
  final double quantity;
  final String? unit;
  final DateTime? expiryDate;
  final String? notes;
  final String? dosageForm;
  final String? strength;
  
  // حقول مرتبطة (من JOIN)
  final String? itemName;
  final String? itemCode;
  final String? medicineCategory;
  final String? unitOfMeasure;
  final String? storeName;
  final String? location;

  MedicineItem({
    this.id,
    required this.movementDate,
    required this.movementType,
    this.itemId,
    this.storeId,
    this.sourceOrRecipient,
    this.medicineType,
    this.packaging,
    required this.quantity,
    this.unit,
    this.expiryDate,
    this.notes,
    this.dosageForm,
    this.strength,
    this.itemName,
    this.itemCode,
    this.medicineCategory,
    this.unitOfMeasure,
    this.storeName,
    this.location,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      id: json['id'],
      movementDate: DateTime.parse(json['movement_date'] ?? DateTime.now().toString()),
      movementType: json['movement_type_ar'] ?? json['movement_type'] ?? '',
      itemId: json['item_id'],
      storeId: json['store_id'],
      sourceOrRecipient: json['source_or_recipient'],
      medicineType: json['medicine_type'],
      packaging: json['packaging'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      notes: json['notes'],
      dosageForm: json['dosage_form'],
      strength: json['strength'],
      itemName: json['item_name'],
      itemCode: json['item_code'],
      medicineCategory: json['medicine_category'],
      unitOfMeasure: json['unit_of_measure'],
      storeName: json['store_name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'movement_date': movementDate.toIso8601String().split('T')[0],
      'movement_type': movementType == 'وارد' ? 'incoming' : 'outgoing',
      'item_id': itemId,
      'store_id': storeId,
      'source_or_recipient': sourceOrRecipient,
      'medicine_type': medicineType,
      'packaging': packaging,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'dosage_form': dosageForm,
      'strength': strength,
    };
  }

  // دوال مساعدة
  String get description => movementType;
  
  Color get typeColor => movementType == 'وارد' ? Colors.green : Colors.orange;
  IconData get typeIcon => movementType == 'وارد' ? Icons.local_pharmacy : Icons.medical_services;
  
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

  // إضافة دالة copyWith المحدثة
  MedicineItem copyWith({
    int? id,
    DateTime? movementDate,
    String? movementType,
    int? itemId,
    int? storeId,
    String? sourceOrRecipient,
    String? medicineType,
    String? packaging,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? notes,
    String? dosageForm,
    String? strength,
    String? itemName, // إضافة هذا الحقل
  }) {
    return MedicineItem(
      id: id ?? this.id,
      movementDate: movementDate ?? this.movementDate,
      movementType: movementType ?? this.movementType,
      itemId: itemId ?? this.itemId,
      storeId: storeId ?? this.storeId,
      sourceOrRecipient: sourceOrRecipient ?? this.sourceOrRecipient,
      medicineType: medicineType ?? this.medicineType,
      packaging: packaging ?? this.packaging,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      itemName: itemName ?? this.itemName, // إضافة هذا السطر
      itemCode: this.itemCode,
      medicineCategory: this.medicineCategory,
      unitOfMeasure: this.unitOfMeasure,
      storeName: this.storeName,
      location: this.location,
    );
  }
}