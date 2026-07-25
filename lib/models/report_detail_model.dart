class ReportDetailModel {
  final BebanUldModel? bebanUld;
  final List<BebanMesinModel> bebanMesin;

  ReportDetailModel({
    this.bebanUld,
    required this.bebanMesin,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    var rawMesinList = json['beban_mesin'] as List? ?? [];
    List<BebanMesinModel> parsedMesin = rawMesinList
        .map((m) => BebanMesinModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return ReportDetailModel(
      bebanUld: json['beban_uld'] != null
          ? BebanUldModel.fromJson(json['beban_uld'] as Map<String, dynamic>)
          : null,
      bebanMesin: parsedMesin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beban_uld': bebanUld?.toJson(),
      'beban_mesin': bebanMesin.map((m) => m.toJson()).toList(),
    };
  }
}

class BebanUldModel {
  final String idBeban;
  final String kdUnit;
  final String namaUnit;
  final String tanggal;
  final String jam;

  BebanUldModel({
    required this.idBeban,
    required this.kdUnit,
    required this.namaUnit,
    required this.tanggal,
    required this.jam,
  });

  factory BebanUldModel.fromJson(Map<String, dynamic> json) {
    return BebanUldModel(
      idBeban: json['id_beban'] as String? ?? '',
      kdUnit: json['kd_unit'] as String? ?? '',
      namaUnit: json['nama_unit'] as String? ?? '',
      tanggal: json['tanggal'] as String? ?? '',
      jam: json['jam'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_beban': idBeban,
      'kd_unit': kdUnit,
      'nama_unit': namaUnit,
      'tanggal': tanggal,
      'jam': jam,
    };
  }
}

class BebanMesinModel {
  final String idBeban;
  final String idMesin;
  final String namaMesin;
  final String noSeri;
  final String? kodeMesinSilm;
  final String kdStatus;
  final double dayaMampu;
  final double? beban;
  final double? standKwh;
  final double? standBbm;
  final String? jkm;
  final double? tekOli;
  final double? temAir;
  final double? arusR;
  final double? arusS;
  final double? arusT;
  final double? teg;
  final String? cosPhi;
  final double? frequency;
  final String keterangan;
  final String? operatorName;

  BebanMesinModel({
    required this.idBeban,
    required this.idMesin,
    required this.namaMesin,
    required this.noSeri,
    this.kodeMesinSilm,
    required this.kdStatus,
    required this.dayaMampu,
    this.beban,
    this.standKwh,
    this.standBbm,
    this.jkm,
    this.tekOli,
    this.temAir,
    this.arusR,
    this.arusS,
    this.arusT,
    this.teg,
    this.cosPhi,
    this.frequency,
    required this.keterangan,
    this.operatorName,
  });

  factory BebanMesinModel.fromJson(Map<String, dynamic> json) {
    return BebanMesinModel(
      idBeban: json['id_beban'] as String? ?? '',
      idMesin: json['id_mesin'] as String? ?? '',
      namaMesin: json['nama_mesin'] as String? ?? '',
      noSeri: json['no_seri'] as String? ?? '',
      kodeMesinSilm: json['kode_mesin_silm'] as String?,
      kdStatus: json['kd_status'] as String? ?? '02',
      dayaMampu: (json['daya_mampu'] as num? ?? 0).toDouble(),
      beban: (json['beban'] as num?)?.toDouble(),
      standKwh: (json['stand_kwh'] as num?)?.toDouble(),
      standBbm: (json['stand_bbm'] as num?)?.toDouble(),
      jkm: json['jkm']?.toString(),
      tekOli: (json['tek_oli'] as num?)?.toDouble(),
      temAir: (json['tem_air'] as num?)?.toDouble(),
      arusR: (json['arus_r'] as num?)?.toDouble(),
      arusS: (json['arus_s'] as num?)?.toDouble(),
      arusT: (json['arus_t'] as num?)?.toDouble(),
      teg: (json['teg'] as num?)?.toDouble(),
      cosPhi: json['cos_phi']?.toString(),
      frequency: (json['frequency'] as num?)?.toDouble(),
      keterangan: json['keterangan'] as String? ?? '',
      operatorName: json['operator'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_beban': idBeban,
      'id_mesin': idMesin,
      'nama_mesin': namaMesin,
      'no_seri': noSeri,
      'kode_mesin_silm': kodeMesinSilm,
      'kd_status': kdStatus,
      'daya_mampu': dayaMampu,
      'beban': beban,
      'stand_kwh': standKwh,
      'stand_bbm': standBbm,
      'jkm': jkm,
      'tek_oli': tekOli,
      'tem_air': temAir,
      'arus_r': arusR,
      'arus_s': arusS,
      'arus_t': arusT,
      'teg': teg,
      'cos_phi': cosPhi,
      'frequency': frequency,
      'keterangan': keterangan,
      'operator': operatorName,
    };
  }
}
