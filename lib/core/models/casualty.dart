import 'package:resistance_system_app/core/utils/data_parser.dart';

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
  bool get isMartyr =>
      (caseType ?? '').contains('شهيد') ||
      (caseType ?? '').toLowerCase().contains('martyr');
  bool get isInjured =>
      (caseType ?? '').contains('جريح') ||
      (caseType ?? '').toLowerCase().contains('injured');

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
      'recovery_return_date': recoveryReturnDate?.toIso8601String().split(
        'T',
      )[0],
      'martyr_protocol_date': martyrProtocolDate?.toIso8601String().split(
        'T',
      )[0],
      'injury_description': injuryDescription,
      'treatment_history': treatmentHistory,
      'continues_after_martyrdom': continuesAfterMartyrdom,
      'permanent_disability': permanentDisability,
    };
  }

  factory Casualty.fromJson(Map<String, dynamic> json) {
    return Casualty(
      id: json['id'], // Usually direct match
      personnelId: json['personnel_id'] ?? json['personnelId'],
      caseType: DataParser.smartGetString(
        json,
        'case_type',
        defaultValue: 'جريح',
      ),
      incidentDate: DataParser.smartGetDate(json, 'incident_date'),
      incidentLocation: DataParser.smartGetString(
        json,
        'incident_location',
        defaultValue: '',
      ),
      signalNumber: DataParser.smartGetString(
        json,
        'signal_number',
        defaultValue: '',
      ),
      injurySeverity: DataParser.smartGetString(
        json,
        'injury_severity',
        defaultValue: 'بسيطة',
      ),
      hospitals: DataParser.smartGetString(json, 'hospitals', defaultValue: ''),
      burialLocation: DataParser.smartGetString(
        json,
        'burial_location',
        defaultValue: '',
      ),
      graveCoordinates: DataParser.smartGetString(
        json,
        'grave_coordinates',
        defaultValue: '',
      ),
      nextOfKinName: DataParser.smartGetString(
        json,
        'next_of_kin_name',
        defaultValue: '',
      ),
      nextOfKinPhone: DataParser.smartGetString(
        json,
        'next_of_kin_phone',
        defaultValue: '',
      ),
      nextOfKinAddress: DataParser.smartGetString(
        json,
        'next_of_kin_address',
        defaultValue: '',
      ),
      notes: DataParser.smartGetString(json, 'notes', defaultValue: ''),
      recoveryReturnDate: DataParser.smartGetDate(json, 'recovery_return_date'),
      martyrProtocolDate: DataParser.smartGetDate(json, 'martyr_protocol_date'),
      injuryDescription: DataParser.smartGetString(
        json,
        'injury_description',
        defaultValue: '',
      ),
      treatmentHistory: DataParser.smartGetString(
        json,
        'treatment_history',
        defaultValue: '',
      ),
      continuesAfterMartyrdom: json['continues_after_martyrdom'] ?? true,
      permanentDisability: json['permanent_disability'] ?? false,

      // Mapped only for display if available
      militaryNumber: DataParser.smartGetString(
        json,
        'military_number',
        defaultValue: '',
      ),
      fullName: DataParser.smartGetString(
        json,
        'personnel_name',
        defaultValue: DataParser.smartGetString(
          json,
          'full_name',
          defaultValue: 'غير معروف',
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'Casualty(id: $id, personnelId: $personnelId, caseType: $caseType, incidentDate: $incidentDate)';
  }
}
