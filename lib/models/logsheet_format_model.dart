class LogsheetFormatModel {
  final LogsheetUnitInfo? unit;
  final LogsheetFormatDetail? format;

  LogsheetFormatModel({this.unit, this.format});

  factory LogsheetFormatModel.fromJson(Map<String, dynamic> json) {
    return LogsheetFormatModel(
      unit: json['unit'] != null
          ? LogsheetUnitInfo.fromJson(json['unit'] as Map<String, dynamic>)
          : null,
      format: json['format'] != null
          ? LogsheetFormatDetail.fromJson(json['format'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit': unit?.toJson(),
      'format': format?.toJson(),
    };
  }
}

class LogsheetUnitInfo {
  final String kdUnit;
  final String namaUnit;
  final String kdRegion;
  final String kdArea;
  final String namaArea;

  LogsheetUnitInfo({
    required this.kdUnit,
    required this.namaUnit,
    required this.kdRegion,
    required this.kdArea,
    required this.namaArea,
  });

  factory LogsheetUnitInfo.fromJson(Map<String, dynamic> json) {
    return LogsheetUnitInfo(
      kdUnit: json['kd_unit'] as String,
      namaUnit: json['nama_unit'] as String,
      kdRegion: json['kd_region'] as String,
      kdArea: json['kd_area'] as String? ?? '',
      namaArea: json['nama_area'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kd_unit': kdUnit,
      'nama_unit': namaUnit,
      'kd_region': kdRegion,
      'kd_area': kdArea,
      'nama_area': namaArea,
    };
  }
}

class LogsheetFormatDetail {
  final String title;
  final String unitName;
  final String unitCode;
  final String date;
  final String time;
  final String operatorName;
  final List<MesinModel> mesin;
  final String text;

  LogsheetFormatDetail({
    required this.title,
    required this.unitName,
    required this.unitCode,
    required this.date,
    required this.time,
    required this.operatorName,
    required this.mesin,
    required this.text,
  });

  factory LogsheetFormatDetail.fromJson(Map<String, dynamic> json) {
    var mesinList = json['mesin'] as List? ?? [];
    List<MesinModel> parsedMesin =
        mesinList.map((m) => MesinModel.fromJson(m as Map<String, dynamic>)).toList();

    return LogsheetFormatDetail(
      title: json['title'] as String? ?? 'LAPORAN LOGSHEET PLTD',
      unitName: json['unit_name'] as String? ?? '',
      unitCode: json['unit_code'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      operatorName: json['operator_name'] as String? ?? '',
      mesin: parsedMesin,
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'unit_name': unitName,
      'unit_code': unitCode,
      'date': date,
      'time': time,
      'operator_name': operatorName,
      'mesin': mesin.map((m) => m.toJson()).toList(),
      'text': text,
    };
  }
}

class MesinModel {
  final int nomor;
  final String namaMesin;
  final String idMesin;
  final String kodeMesinSilm;
  final String sn;
  final int dt;
  final String kdJenisBahanBakar;

  MesinModel({
    required this.nomor,
    required this.namaMesin,
    required this.idMesin,
    required this.kodeMesinSilm,
    required this.sn,
    required this.dt,
    required this.kdJenisBahanBakar,
  });

  factory MesinModel.fromJson(Map<String, dynamic> json) {
    return MesinModel(
      nomor: json['nomor'] as int? ?? 0,
      namaMesin: json['nama_mesin'] as String? ?? '',
      idMesin: json['id_mesin'] as String? ?? '',
      kodeMesinSilm: json['kode_mesin_silm'] as String? ?? '',
      sn: json['sn'] as String? ?? '',
      dt: json['dt'] as int? ?? 0,
      kdJenisBahanBakar: json['kd_jenis_bahan_bakar'] as String? ?? 'B35',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'nama_mesin': namaMesin,
      'id_mesin': idMesin,
      'kode_mesin_silm': kodeMesinSilm,
      'sn': sn,
      'dt': dt,
      'kd_jenis_bahan_bakar': kdJenisBahanBakar,
    };
  }
}
