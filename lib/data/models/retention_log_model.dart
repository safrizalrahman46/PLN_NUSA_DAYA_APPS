class RetentionLogModel {
  const RetentionLogModel({
    required this.id,
    required this.createdAt,
    required this.action,
    required this.affectedCount,
    this.fileName = '',
    this.note = '',
  });

  final String id;
  final DateTime createdAt;
  final String action;
  final int affectedCount;
  final String fileName;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'action': action,
    'affectedCount': affectedCount,
    'fileName': fileName,
    'note': note,
  };

  factory RetentionLogModel.fromJson(Map<String, dynamic> json) {
    return RetentionLogModel(
      id: json['id']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      action: json['action']?.toString() ?? '',
      affectedCount: (json['affectedCount'] as num?)?.toInt() ?? 0,
      fileName: json['fileName']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}
