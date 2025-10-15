import 'package:flutter/material.dart';

class Casualty {
  int? id;
  int? personnelId;
  String? militaryNumber;
  String? fullName;
  String formType; // شهيد - جريح
  DateTime incidentDate;
  String incidentLocation;
  String caseSignalNumber;
  String injurySeverity; // خطيرة - محدودة - بسيطة - بسيطة جدا
  String? treatmentHistory;
  String? hospitals;
  String? burialLocation;
  String? graveCoordinates;
  
  // خلافة الشهيد (سيتم نقلها لجدول منفصل)
  DateTime? compensationDate;
  double? compensationAmount;
  String? paymentMethod;
  String? compensationRecipient;
  String? payingEntity;
  String? materialItems;
  double? materialValue;
  
  DateTime? createdAt;
  DateTime? updatedAt;

  Casualty({
    this.id,
    this.personnelId,
    this.militaryNumber,
    this.fullName,
    required this.formType,
    required this.incidentDate,
    required this.incidentLocation,
    required this.caseSignalNumber,
    required this.injurySeverity,
    this.treatmentHistory,
    this.hospitals,
    this.burialLocation,
    this.graveCoordinates,
    this.compensationDate,
    this.compensationAmount,
    this.paymentMethod,
    this.compensationRecipient,
    this.payingEntity,
    this.materialItems,
    this.materialValue,
    this.createdAt,
    this.updatedAt,
  });

  factory Casualty.fromJson(Map<String, dynamic> json) {
    return Casualty(
      id: json['id'],
      personnelId: json['personnel_id'],
      militaryNumber: json['military_number'],
      fullName: json['full_name'],
      formType: json['form_type'] ?? '',
      incidentDate: json['incident_date'] != null 
          ? DateTime.parse(json['incident_date']) 
          : DateTime.now(),
      incidentLocation: json['incident_location'] ?? '',
      caseSignalNumber: json['case_signal_number'] ?? '',
      injurySeverity: json['injury_severity'] ?? '',
      treatmentHistory: json['treatment_history'],
      hospitals: json['hospitals'],
      burialLocation: json['burial_location'],
      graveCoordinates: json['grave_coordinates'],
      compensationDate: json['compensation_date'] != null 
          ? DateTime.parse(json['compensation_date']) 
          : null,
      compensationAmount: json['compensation_amount'] != null 
          ? double.parse(json['compensation_amount'].toString()) 
          : null,
      paymentMethod: json['payment_method'],
      compensationRecipient: json['compensation_recipient'],
      payingEntity: json['paying_entity'],
      materialItems: json['material_items'],
      materialValue: json['material_value'] != null 
          ? double.parse(json['material_value'].toString()) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'personnel_id': personnelId,
      'form_type': formType,
      'incident_date': incidentDate.toIso8601String(),
      'incident_location': incidentLocation,
      'case_signal_number': caseSignalNumber,
      'injury_severity': injurySeverity,
      'treatment_history': treatmentHistory,
      'hospitals': hospitals,
      'burial_location': burialLocation,
      'grave_coordinates': graveCoordinates,
      'compensation_date': compensationDate?.toIso8601String(),
      'compensation_amount': compensationAmount,
      'payment_method': paymentMethod,
      'compensation_recipient': compensationRecipient,
      'paying_entity': payingEntity,
      'material_items': materialItems,
      'material_value': materialValue,
    };
  }

  // دوال مساعدة
  Color get typeColor {
    return formType == 'شهيد' ? Colors.red : Colors.orange;
  }

  Color get severityColor {
    switch (injurySeverity) {
      case 'خطيرة':
        return Colors.red;
      case 'محدودة':
        return Colors.orange;
      case 'بسيطة':
        return Colors.yellow;
      case 'بسيطة جدا':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get incidentDateFormatted {
    return '${incidentDate.year}-${incidentDate.month.toString().padLeft(2, '0')}-${incidentDate.day.toString().padLeft(2, '0')}';
  }

  bool get isMartyr => formType == 'شهيد';
  bool get isInjured => formType == 'جريح';
}