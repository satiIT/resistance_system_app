class TrainingRecord {
  int? id;
  int personnelId;
  int courseId;
  String? attendanceStatus;
  int? evaluationScore;
  bool? certificateReceived;
  String? notes;
  DateTime? joinedAt;
  String? priorTrainingType;
  String? firingLocation;
  String? weaponType;
  String? trainingCampName;
  String? specializedCourseType;
  String? weaponTrainingType;

  // علاقات مع الجداول الأخرى
  String? personnelName;
  String? militaryNumber;
  String? courseName;
  String? courseType;
  String? courseLocation;
  DateTime? courseStartDate;
  DateTime? courseEndDate;
  int? courseDurationDays;

  TrainingRecord({
    this.id,
    required this.personnelId,
    required this.courseId,
    this.attendanceStatus,
    this.evaluationScore,
    this.certificateReceived,
    this.notes,
    this.joinedAt,
    this.priorTrainingType,
    this.firingLocation,
    this.weaponType,
    this.trainingCampName,
    this.specializedCourseType,
    this.weaponTrainingType,
    this.personnelName,
    this.militaryNumber,
    this.courseName,
    this.courseType,
    this.courseLocation,
    this.courseStartDate,
    this.courseEndDate,
    this.courseDurationDays,
  });

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'],
      personnelId: json['personnel_id'],
      courseId: json['course_id'],
      attendanceStatus: json['attendance_status'],
      evaluationScore: json['evaluation_score'],
      certificateReceived: json['certificate_received'],
      notes: json['notes'],
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at']) : null,
      priorTrainingType: json['prior_training_type'],
      firingLocation: json['firing_location'],
      weaponType: json['weapon_type'],
      trainingCampName: json['training_camp_name'],
      specializedCourseType: json['specialized_course_type'],
      weaponTrainingType: json['weapon_training_type'],
      personnelName: json['personnel_name'],
      militaryNumber: json['military_number'],
      courseName: json['course_name'],
      courseType: json['course_type'],
      courseLocation: json['course_location'],
      courseStartDate: json['course_start_date'] != null ? DateTime.parse(json['course_start_date']) : null,
      courseEndDate: json['course_end_date'] != null ? DateTime.parse(json['course_end_date']) : null,
      courseDurationDays: json['course_duration_days'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personnel_id': personnelId,
      'course_id': courseId,
      'attendance_status': attendanceStatus,
      'evaluation_score': evaluationScore,
      'certificate_received': certificateReceived,
      'notes': notes,
      'joined_at': joinedAt?.toIso8601String(),
      'prior_training_type': priorTrainingType,
      'firing_location': firingLocation,
      'weapon_type': weaponType,
      'training_camp_name': trainingCampName,
      'specialized_course_type': specializedCourseType,
      'weapon_training_type': weaponTrainingType,
    };
  }
}