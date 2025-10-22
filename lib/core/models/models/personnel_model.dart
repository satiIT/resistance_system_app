class Personnel {
  final String id;
  final String firstName;
  final String secondName;
  final String thirdName;
  final String fourthName;
  final String nationalId;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String militaryId;
  final String rank;
  final String unit;
  final String status;
  final String enlistmentDate;
  final String phoneNumber;
  final String email;
  final String address;
  final String emergencyContactPhone;
  final String motherFullName;
  final int wivesCount;
  final int childrenCount;
  final int dependentsCount;
  final String state;
  final String locality;
  final String administrativeUnit;
  final String cityVillage;
  final String educationLevel;
  final String occupation;
  final String skills;
  final String healthConditions;

  Personnel({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.thirdName,
    required this.fourthName,
    required this.nationalId,
    required this.birthDate,
    required this.gender,
    required this.maritalStatus,
    required this.militaryId,
    required this.rank,
    required this.unit,
    required this.status,
    required this.enlistmentDate,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.emergencyContactPhone,
    required this.motherFullName,
    required this.wivesCount,
    required this.childrenCount,
    required this.dependentsCount,
    required this.state,
    required this.locality,
    required this.administrativeUnit,
    required this.cityVillage,
    required this.educationLevel,
    required this.occupation,
    required this.skills,
    required this.healthConditions,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      secondName: json['second_name'] ?? '',
      thirdName: json['third_name'] ?? '',
      fourthName: json['fourth_name'] ?? '',
      nationalId: json['national_id'] ?? '',
      birthDate: json['birth_date'] ?? '',
      gender: json['gender'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      militaryId: json['military_id'] ?? '',
      rank: json['rank'] ?? '',
      unit: json['unit'] ?? '',
      status: json['status'] ?? '',
      enlistmentDate: json['enlistment_date'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] ?? '',
      motherFullName: json['mother_full_name'] ?? '',
      wivesCount: json['wives_count'] ?? 0,
      childrenCount: json['children_count'] ?? 0,
      dependentsCount: json['dependents_count'] ?? 0,
      state: json['state'] ?? '',
      locality: json['locality'] ?? '',
      administrativeUnit: json['administrative_unit'] ?? '',
      cityVillage: json['city_village'] ?? '',
      educationLevel: json['education_level'] ?? '',
      occupation: json['occupation'] ?? '',
      skills: json['skills'] ?? '',
      healthConditions: json['health_conditions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'second_name': secondName,
      'third_name': thirdName,
      'fourth_name': fourthName,
      'national_id': nationalId,
      'birth_date': birthDate,
      'gender': gender,
      'marital_status': maritalStatus,
      'military_id': militaryId,
      'rank': rank,
      'unit': unit,
      'status': status,
      'enlistment_date': enlistmentDate,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'emergency_contact_phone': emergencyContactPhone,
      'mother_full_name': motherFullName,
      'wives_count': wivesCount,
      'children_count': childrenCount,
      'dependents_count': dependentsCount,
      'state': state,
      'locality': locality,
      'administrative_unit': administrativeUnit,
      'city_village': cityVillage,
      'education_level': educationLevel,
      'occupation': occupation,
      'skills': skills,
      'health_conditions': healthConditions,
    };
  }
}