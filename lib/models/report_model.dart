class ReportModel {
  final int id;
  final String kdRegion;
  final String kdUnit;
  final String namaUnit;
  final int jamOperasional;
  final Map<String, LogsheetSlotStatus> logsheetPltd;

  ReportModel({
    required this.id,
    required this.kdRegion,
    required this.kdUnit,
    required this.namaUnit,
    required this.jamOperasional,
    required this.logsheetPltd,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    var rawSlots = json['logsheet_pltd'] as Map<String, dynamic>? ?? {};
    Map<String, LogsheetSlotStatus> parsedSlots = {};
    
    rawSlots.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        parsedSlots[key] = LogsheetSlotStatus.fromJson(value);
      }
    });

    return ReportModel(
      id: json['id'] as int? ?? 0,
      kdRegion: json['kd_region'] as String? ?? '05',
      kdUnit: json['kd_unit'] as String? ?? '',
      namaUnit: json['nama_unit'] as String? ?? '',
      jamOperasional: json['jam_operasional'] as int? ?? 24,
      logsheetPltd: parsedSlots,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> serializedSlots = {};
    logsheetPltd.forEach((key, value) {
      serializedSlots[key] = value.toJson();
    });

    return {
      'id': id,
      'kd_region': kdRegion,
      'kd_unit': kdUnit,
      'nama_unit': namaUnit,
      'jam_operasional': jamOperasional,
      'logsheet_pltd': serializedSlots,
    };
  }
}

class LogsheetSlotStatus {
  final String status;
  final String? idBeban;

  LogsheetSlotStatus({
    required this.status,
    this.idBeban,
  });

  bool get isDone => status.toLowerCase() == 'done';

  factory LogsheetSlotStatus.fromJson(Map<String, dynamic> json) {
    return LogsheetSlotStatus(
      status: json['status'] as String? ?? 'not done',
      idBeban: json['id_beban'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'id_beban': idBeban,
    };
  }
}
