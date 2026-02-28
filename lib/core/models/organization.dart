class Department {
  final int id;
  final String name;
  final int? governorId;
  final String? governorName;

  Department({
    required this.id,
    required this.name,
    this.governorId,
    this.governorName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      governorId: json['governor_id'],
      governorName: json['governor_name'],
    );
  }
}

class OrgGroup {
  final int id;
  final String name;
  final int deptId;
  final int? governorId;
  final String? governorName;
  final int personnelCount;

  OrgGroup({
    required this.id,
    required this.name,
    required this.deptId,
    this.governorId,
    this.governorName,
    this.personnelCount = 0,
  });

  factory OrgGroup.fromJson(Map<String, dynamic> json) {
    return OrgGroup(
      id: json['id'],
      name: json['name'],
      deptId: json['dept_id'],
      governorId: json['governor_id'],
      governorName: json['governor_name'],
      personnelCount:
          int.tryParse(json['personnel_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class OrgReport {
  final int id;
  final String reportType;
  final int targetId;
  final String targetName;
  final String? note;
  final int createdBy;
  final String? creatorEmail;
  final DateTime createdAt;

  OrgReport({
    required this.id,
    required this.reportType,
    required this.targetId,
    required this.targetName,
    this.note,
    required this.createdBy,
    this.creatorEmail,
    required this.createdAt,
  });

  factory OrgReport.fromJson(Map<String, dynamic> json) {
    return OrgReport(
      id: json['id'],
      reportType: json['report_type'],
      targetId: json['target_id'],
      targetName: json['target_name'] ?? 'غير معروف',
      note: json['note'],
      createdBy: json['created_by'],
      creatorEmail: json['creator_email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
