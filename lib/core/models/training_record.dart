class TrainingRecord {
  int? id;
  int? personnelId;
  String? personnelName;
  String? militaryNumber;
  String? previousTrainingType;
  String? trainingCampCourseName;
  String? trainingCampWeaponName;
  int? trainingCampDuration;
  String? trainingCampFiringRange;
  String? specializedCourseType;
  String? specializedCourseDetails;
  String? weaponTypeReceived;
  String? weaponNumber;
  List<String>? weaponAccessories;
  DateTime? createdAt;
  DateTime? updatedAt;

  TrainingRecord({
    this.id,
    this.personnelId,
    this.personnelName,
    this.militaryNumber,
    this.previousTrainingType,
    this.trainingCampCourseName,
    this.trainingCampWeaponName,
    this.trainingCampDuration,
    this.trainingCampFiringRange,
    this.specializedCourseType,
    this.specializedCourseDetails,
    this.weaponTypeReceived,
    this.weaponNumber,
    this.weaponAccessories,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'],
      personnelId: json['personnel_id'],
      personnelName: json['personnel_name'],
      militaryNumber: json['military_number'],
      previousTrainingType: json['previous_training_type'],
      trainingCampCourseName: json['training_camp_course_name'],
      trainingCampWeaponName: json['training_camp_weapon_name'],
      trainingCampDuration: json['training_camp_duration'],
      trainingCampFiringRange: json['training_camp_firing_range'],
      specializedCourseType: json['specialized_course_type'],
      specializedCourseDetails: json['specialized_course_details'],
      weaponTypeReceived: json['weapon_type_received'],
      weaponNumber: json['weapon_number'],
      weaponAccessories: json['weapon_accessories'] != null 
          ? List<String>.from(json['weapon_accessories'])
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
      'personnel_id': personnelId,
      'military_number': militaryNumber,
      'previous_training_type': previousTrainingType,
      'training_camp_course_name': trainingCampCourseName,
      'training_camp_weapon_name': trainingCampWeaponName,
      'training_camp_duration': trainingCampDuration,
      'training_camp_firing_range': trainingCampFiringRange,
      'specialized_course_type': specializedCourseType,
      'specialized_course_details': specializedCourseDetails,
      'weapon_type_received': weaponTypeReceived,
      'weapon_number': weaponNumber,
      'weapon_accessories': weaponAccessories,
    };
  }
}