import 'package:flutter/material.dart';

class Casualty {
  int? id;
  String militaryNumber;
  String formType; // شهيد - جريح
  String fullName;
  DateTime incidentDate;
  String incidentLocation;
  String caseSignalNumber;
  String injurySeverity; // خطيرة - محدودة - بسيطة - بسيطة جدا
  String? hospitals; // المستشفيات التي تعالج فيها الجريح
  String? burialLocation; // مكان دفن الشهيد
  String? graveCoordinates; // إحداثيات قبر الشهيد
  String nextOfKinName; // اسم أقرب الأقربين
  String nextOfKinPhone; // رقم تلفون أقرب الأقربين
  String? nextOfKinAddress; // عنوان أقرب الأقربين
  
  // خلافة الشهيد
  DateTime? compensationDate;
  double? compensationAmount;
  String? paymentMethod; // نقدا - بنك
  String? compensationRecipient; // الشخص المستلم للمبلغ
  String? payingEntity; // الجهة الدافعة للمبلغ
  String? materialItems; // نوع المواد العينية
  double? materialValue; // تقدير قيمتها
  
  DateTime? createdAt;
  DateTime? updatedAt;

  Casualty({
    this.id,
    required this.militaryNumber,
    required this.formType,
    required this.fullName,
    required this.incidentDate,
    required this.incidentLocation,
    required this.caseSignalNumber,
    required this.injurySeverity,
    this.hospitals,
    this.burialLocation,
    this.graveCoordinates,
    required this.nextOfKinName,
    required this.nextOfKinPhone,
    this.nextOfKinAddress,
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
      militaryNumber: json['military_number'] ?? '',
      formType: json['form_type'] ?? '',
      fullName: json['full_name'] ?? '',
      incidentDate: json['incident_date'] != null 
          ? DateTime.parse(json['incident_date']) 
          : DateTime.now(),
      incidentLocation: json['incident_location'] ?? '',
      caseSignalNumber: json['case_signal_number'] ?? '',
      injurySeverity: json['injury_severity'] ?? '',
      hospitals: json['hospitals'],
      burialLocation: json['burial_location'],
      graveCoordinates: json['grave_coordinates'],
      nextOfKinName: json['next_of_kin_name'] ?? '',
      nextOfKinPhone: json['next_of_kin_phone'] ?? '',
      nextOfKinAddress: json['next_of_kin_address'],
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
      'military_number': militaryNumber,
      'form_type': formType,
      'full_name': fullName,
      'incident_date': incidentDate.toIso8601String(),
      'incident_location': incidentLocation,
      'case_signal_number': caseSignalNumber,
      'injury_severity': injurySeverity,
      'hospitals': hospitals,
      'burial_location': burialLocation,
      'grave_coordinates': graveCoordinates,
      'next_of_kin_name': nextOfKinName,
      'next_of_kin_phone': nextOfKinPhone,
      'next_of_kin_address': nextOfKinAddress,
      'compensation_date': compensationDate?.toIso8601String(),
      'compensation_amount': compensationAmount,
      'payment_method': paymentMethod,
      'compensation_recipient': compensationRecipient,
      'paying_entity': payingEntity,
      'material_items': materialItems,
      'material_value': materialValue,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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