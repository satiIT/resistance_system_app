// core/models/financial_item.dart
import 'package:flutter/material.dart';

class FinancialItem {
  final int? id;
  final DateTime entryDate;
  final String type; // 'incoming' أو 'outgoing'
  final String source; // للوارد: الجهة الموردة، للمنصرف: بند الصرف
  final double amount;
  final String method; // للوارد: طريقة التوريد، للمنصرف: الشخص المستلم
  final String? notes;

  FinancialItem({
    this.id,
    required this.entryDate,
    required this.type,
    required this.source,
    required this.amount,
    required this.method,
    this.notes,
  });

  factory FinancialItem.fromJson(Map<String, dynamic> json) {
    return FinancialItem(
      id: json['id'],
      entryDate: DateTime.parse(json['entry_date'] ?? DateTime.now().toString()),
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'entry_date': entryDate.toIso8601String().split('T')[0],
      'type': type,
      'source': source,
      'amount': amount,
      'method': method,
      'notes': notes,
    };
  }

  // دوال مساعدة
  String get description => type == 'incoming' ? 'وارد' : 'منصرف';
  
  Color get typeColor => type == 'incoming' ? Colors.green : Colors.orange;
  IconData get typeIcon => type == 'incoming' ? Icons.trending_up : Icons.trending_down;
  
  String get displaySource => type == 'incoming' ? 'الجهة: $source' : 'بند الصرف: $source';
  String get displayMethod => type == 'incoming' ? 'طريقة التوريد: $method' : 'المستلم: $method';

  FinancialItem copyWith({
    int? id,
    DateTime? entryDate,
    String? type,
    String? source,
    double? amount,
    String? method,
    String? notes,
  }) {
    return FinancialItem(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      type: type ?? this.type,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      notes: notes ?? this.notes,
    );
  }
}