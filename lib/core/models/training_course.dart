import 'dart:ui';

import 'package:flutter/material.dart';

class TrainingCourse {
  int? id;
  String courseName;
  String? courseType;
  String? location;
  DateTime? startDate;
  DateTime? endDate;
  int? durationDays;
  String? organizer;
  bool? certificateIssued;
  String? notes;
  DateTime? createdAt;
  String? courseLevel;
  String? targetGroup;
  String? instructorName;
  String? instructorRank;
  String? instructorUnit;
  String? prerequisites;
  int? maxParticipants;
  String? courseStatus;
  bool? isActive;
  String? courseMaterialUrl;
  String? evaluationFormUrl;
  String? trainingWeaponName;

  TrainingCourse({
    this.id,
    required this.courseName,
    this.courseType,
    this.location,
    this.startDate,
    this.endDate,
    this.durationDays,
    this.organizer,
    this.certificateIssued = false,
    this.notes,
    this.createdAt,
    this.courseLevel,
    this.targetGroup,
    this.instructorName,
    this.instructorRank,
    this.instructorUnit,
    this.prerequisites,
    this.maxParticipants,
    this.courseStatus = 'مخطط',
    this.isActive = true,
    this.courseMaterialUrl,
    this.evaluationFormUrl,
    this.trainingWeaponName,
  }) {
    // تعيين القيم الافتراضية
    createdAt ??= DateTime.now();
  }

  factory TrainingCourse.fromJson(Map<String, dynamic> json) {
    return TrainingCourse(
      id: json['id'],
      courseName: json['course_name'] ?? '',
      courseType: json['course_type'],
      location: json['location'],
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      durationDays: json['duration_days'],
      organizer: json['organizer'],
      certificateIssued: json['certificate_issued'] ?? false,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : DateTime.now(),
      courseLevel: json['course_level'],
      targetGroup: json['target_group'],
      instructorName: json['instructor_name'],
      instructorRank: json['instructor_rank'],
      instructorUnit: json['instructor_unit'],
      prerequisites: json['prerequisites'],
      maxParticipants: json['max_participants'],
      courseStatus: json['course_status'] ?? 'مخطط',
      isActive: json['is_active'] ?? true,
      courseMaterialUrl: json['course_material_url'],
      evaluationFormUrl: json['evaluation_form_url'],
      trainingWeaponName: json['training_weapon_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'course_name': courseName,
      'course_type': courseType,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_days': durationDays,
      'organizer': organizer,
      'certificate_issued': certificateIssued,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'course_level': courseLevel,
      'target_group': targetGroup,
      'instructor_name': instructorName,
      'instructor_rank': instructorRank,
      'instructor_unit': instructorUnit,
      'prerequisites': prerequisites,
      'max_participants': maxParticipants,
      'course_status': courseStatus,
      'is_active': isActive,
      'course_material_url': courseMaterialUrl,
      'evaluation_form_url': evaluationFormUrl,
      'training_weapon_name': trainingWeaponName,
    };
  }

  // دالة مساعدة للحصول على حالة الدورة بشكل مرئي
  Color get statusColor {
    switch (courseStatus) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد التنفيذ':
        return Colors.blue;
      case 'مخطط':
        return Colors.orange;
      case 'ملغى':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // دالة مساعدة للتحقق من أن الدورة نشطة
  bool get isActiveCourse {
    return isActive == true && courseStatus != 'ملغى';
  }

  // دالة مساعدة لعرض مدة الدورة
  String get durationText {
    if (durationDays == null) return 'غير محدد';
    return '$durationDays يوم';
  }

  // دالة مساعدة لعرض تاريخ الدورة
  String get dateRangeText {
    if (startDate == null && endDate == null) return 'غير محدد';
    if (startDate == null) return 'حتى ${_formatDate(endDate!)}';
    if (endDate == null) return 'من ${_formatDate(startDate!)}';
    return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}