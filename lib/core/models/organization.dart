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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      governorId: json['governor_id'],
      governorName: json['governor_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governor_id': governorId,
      'governor_name': governorName,
    };
  }
}

class OrgGroup {
  final int id;
  final String name;
  final int deptId;
  final int? governorId;
  final String? governorName;
  final int personnelCount;
  final String? deptName;

  OrgGroup({
    required this.id,
    required this.name,
    required this.deptId,
    this.governorId,
    this.governorName,
    this.personnelCount = 0,
    this.deptName,
  });

  factory OrgGroup.fromJson(Map<String, dynamic> json) {
    // Safely parse int fields that may arrive as strings from the backend
    int _parseInt(dynamic val, [int fallback = 0]) => val == null
        ? fallback
        : (val is int ? val : int.tryParse(val.toString()) ?? fallback);
    int? _parseIntNullable(dynamic val) =>
        val == null ? null : (val is int ? val : int.tryParse(val.toString()));

    return OrgGroup(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      deptId: _parseInt(json['dept_id']),
      governorId: _parseIntNullable(json['governor_id']),
      governorName: json['governor_name'],
      deptName: json['dept_name'],
      personnelCount: _parseInt(json['personnel_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dept_id': deptId,
      'governor_id': governorId,
      'governor_name': governorName,
      'dept_name': deptName,
      'personnel_count': personnelCount,
    };
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
  final DateTime? reportDate;

  OrgReport({
    required this.id,
    required this.reportType,
    required this.targetId,
    required this.targetName,
    this.note,
    required this.createdBy,
    this.creatorEmail,
    required this.createdAt,
    this.reportDate,
  });

  factory OrgReport.fromJson(Map<String, dynamic> json) {
    return OrgReport(
      id: json['id'] ?? 0,
      reportType: json['report_type'] ?? '',
      targetId: json['target_id'] ?? 0,
      targetName: json['target_name'] ?? 'غير معروف',
      note: json['note'],
      createdBy: json['created_by'] ?? 0,
      creatorEmail: json['creator_email'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      reportDate: json['report_date'] != null
          ? DateTime.parse(json['report_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_type': reportType,
      'target_id': targetId,
      'target_name': targetName,
      'note': note,
      'created_by': createdBy,
      'creator_email': creatorEmail,
      'created_at': createdAt.toIso8601String(),
      'report_date': reportDate?.toIso8601String(),
    };
  }
}

class User {
  final int id;
  final String email;
  final String role;
  final int? personnelId;
  final int? departmentId;
  final int? groupId;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.personnelId,
    this.departmentId,
    this.groupId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      personnelId: json['personnel_id'],
      departmentId: json['department_id'],
      groupId: json['group_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
