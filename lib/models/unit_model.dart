class UnitModel {
  final String kdUnit;
  final String namaUnit;
  final String kdRegion;
  final String kdArea;
  final String namaArea;

  UnitModel({
    required this.kdUnit,
    required this.namaUnit,
    required this.kdRegion,
    required this.kdArea,
    required this.namaArea,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
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
