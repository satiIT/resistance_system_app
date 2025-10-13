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
    this.certificateIssued,
    this.notes,
    this.createdAt,
    this.courseLevel,
    this.targetGroup,
    this.instructorName,
    this.instructorRank,
    this.instructorUnit,
    this.prerequisites,
    this.maxParticipants,
    this.courseStatus,
    this.isActive,
    this.courseMaterialUrl,
    this.evaluationFormUrl,
    this.trainingWeaponName,
  });

  factory TrainingCourse.fromJson(Map<String, dynamic> json) {
    return TrainingCourse(
      id: json['id'],
      courseName: json['course_name'],
      courseType: json['course_type'],
      location: json['location'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      durationDays: json['duration_days'],
      organizer: json['organizer'],
      certificateIssued: json['certificate_issued'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      courseLevel: json['course_level'],
      targetGroup: json['target_group'],
      instructorName: json['instructor_name'],
      instructorRank: json['instructor_rank'],
      instructorUnit: json['instructor_unit'],
      prerequisites: json['prerequisites'],
      maxParticipants: json['max_participants'],
      courseStatus: json['course_status'],
      isActive: json['is_active'],
      courseMaterialUrl: json['course_material_url'],
      evaluationFormUrl: json['evaluation_form_url'],
      trainingWeaponName: json['training_weapon_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'course_type': courseType,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_days': durationDays,
      'organizer': organizer,
      'certificate_issued': certificateIssued,
      'notes': notes,
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
}