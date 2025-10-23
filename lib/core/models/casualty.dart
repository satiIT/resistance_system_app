class Casualty {
  int? id;
  int? personnelId;
  String? caseType; // matches 'case_type' in database
  DateTime? incidentDate;
  String? incidentLocation;
  String? signalNumber; // matches 'signal_number' in database
  String? injurySeverity;
  String? hospitals;
  String? burialLocation;
  String? graveCoordinates;
  String? nextOfKinName;
  String? nextOfKinPhone;
  String? nextOfKinAddress;
  String? notes;
  DateTime? recoveryReturnDate;
  DateTime? martyrProtocolDate;
  String? injuryDescription;
  String? treatmentHistory;
  bool? continuesAfterMartyrdom;
  bool? permanentDisability;
  
  // Fields for compensation (only for martyr) - for form use only
  DateTime? compensationDate;
  double? compensationAmount;
  String? paymentMethod;
  String? compensationRecipient;
  String? payingEntity;
  String? materialItems;
  double? materialValue;

  // Computed properties
  bool get isMartyr => caseType == 'شهيد';
  bool get isInjured => caseType == 'جريح';

  // For display in the form (not in database)
  String? militaryNumber;
  String? fullName;

  Casualty({
    this.id,
    this.personnelId,
    this.caseType = 'جريح',
    this.incidentDate,
    this.incidentLocation = '',
    this.signalNumber = '',
    this.injurySeverity = 'بسيطة',
    this.hospitals,
    this.burialLocation,
    this.graveCoordinates,
    this.nextOfKinName,
    this.nextOfKinPhone,
    this.nextOfKinAddress,
    this.notes,
    this.recoveryReturnDate,
    this.martyrProtocolDate,
    this.injuryDescription,
    this.treatmentHistory,
    this.continuesAfterMartyrdom = true,
    this.permanentDisability = false,
    this.compensationDate,
    this.compensationAmount,
    this.paymentMethod,
    this.compensationRecipient,
    this.payingEntity,
    this.materialItems,
    this.materialValue,
    this.militaryNumber,
    this.fullName,
  });

  Map<String, dynamic> toJson() {
    return {
      'personnel_id': personnelId,
      'case_type': caseType,
      'incident_date': incidentDate?.toIso8601String().split('T')[0],
      'incident_location': incidentLocation,
      'signal_number': signalNumber,
      'injury_severity': injurySeverity,
      'hospitals': hospitals,
      'burial_location': burialLocation,
      'grave_coordinates': graveCoordinates,
      'next_of_kin_name': nextOfKinName,
      'next_of_kin_phone': nextOfKinPhone,
      'next_of_kin_address': nextOfKinAddress,
      'notes': notes,
      'recovery_return_date': recoveryReturnDate?.toIso8601String().split('T')[0],
      'martyr_protocol_date': martyrProtocolDate?.toIso8601String().split('T')[0],
      'injury_description': injuryDescription,
      'treatment_history': treatmentHistory,
      'continues_after_martyrdom': continuesAfterMartyrdom,
      'permanent_disability': permanentDisability,
    };
  }

  factory Casualty.fromJson(Map<String, dynamic> json) {
    return Casualty(
      id: json['id'],
      personnelId: json['personnel_id'],
      caseType: json['case_type'],
      incidentDate: DateTime.parse(json['incident_date']),
      incidentLocation: json['incident_location'],
      signalNumber: json['signal_number'],
      injurySeverity: json['injury_severity'],
      hospitals: json['hospitals'],
      burialLocation: json['burial_location'],
      graveCoordinates: json['grave_coordinates'],
      nextOfKinName: json['next_of_kin_name'],
      nextOfKinPhone: json['next_of_kin_phone'],
      nextOfKinAddress: json['next_of_kin_address'],
      notes: json['notes'],
      recoveryReturnDate: json['recovery_return_date'] != null 
          ? DateTime.parse(json['recovery_return_date']) 
          : null,
      martyrProtocolDate: json['martyr_protocol_date'] != null 
          ? DateTime.parse(json['martyr_protocol_date']) 
          : null,
      injuryDescription: json['injury_description'],
      treatmentHistory: json['treatment_history'],
      continuesAfterMartyrdom: json['continues_after_martyrdom'] ?? true,
      permanentDisability: json['permanent_disability'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Casualty(id: $id, personnelId: $personnelId, caseType: $caseType, incidentDate: $incidentDate)';
  }
}