import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/utils/file_exporter.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';

class ReportExportPayload {
  const ReportExportPayload({
    required this.records,
    required this.periodLabel,
    required this.fileNameBase,
    required this.exportedBy,
    required this.dateRangeLabel,
    required this.operatorFieldLabel,
  });

  final List<LogsheetModel> records;
  final String periodLabel;
  final String fileNameBase;
  final String exportedBy;
  final String dateRangeLabel;
  final String operatorFieldLabel;
}

class ReportExportService {
  Future<void> sharePdf(ReportExportPayload payload) async {
    final bytes = await _buildPdfBytes(payload);
    await saveAndShareFile(
      bytes: bytes,
      filename: '${payload.fileNameBase}.pdf',
      mimeType: 'application/pdf',
      shareText: 'Laporan PLN Nusa Daya ${payload.periodLabel}',
    );
  }

  Future<void> shareExcel(ReportExportPayload payload) async {
    final bytes = await _buildExcelBytes(payload);
    await saveAndShareFile(
      bytes: bytes,
      filename: '${payload.fileNameBase}.xlsx',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      shareText: 'Laporan PLN Nusa Daya ${payload.periodLabel}',
    );
  }

  Future<Uint8List> _buildPdfBytes(ReportExportPayload payload) async {
    final doc = pw.Document();
    final logoData = await rootBundle.load('assets/images/PLND.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());
    final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(logo, width: 96, fit: pw.BoxFit.contain),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Laporan PLN Nusa Daya',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Periode: ${payload.periodLabel}'),
                      pw.Text('Rentang: ${payload.dateRangeLabel}'),
                      pw.Text('Dicetak oleh: ${payload.exportedBy}'),
                      pw.Text(
                        'Tanggal cetak: ${dateTimeFormat.format(DateTime.now())}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Row(
              children: [
                _summaryBox('Total Data', '${payload.records.length}'),
                pw.SizedBox(width: 10),
                _summaryBox(
                  'Pending',
                  '${payload.records.where((item) => item.syncStatus != SyncStatus.synced).length}',
                ),
                pw.SizedBox(width: 10),
                _summaryBox(
                  'Abnormal',
                  '${payload.records.where((item) => item.reportStatus == ReportStatus.abnormal).length}',
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
              cellAlignment: pw.Alignment.centerLeft,
              headers: const [
                'Tanggal',
                'Unit',
                'Operator',
                'Mesin',
                'Status Data',
                'Status Laporan',
                'Parameter Utama',
                'Catatan',
              ],
              data: payload.records
                  .map(
                    (item) => [
                      dateTimeFormat.format(item.submittedAt),
                      item.unitName,
                      item.operatorName,
                      item.machineShortLabel,
                      item.lifecycleStatusLabel,
                      item.reportStatus.name,
                      _pdfParameterSummary(item),
                      item.notes,
                    ],
                  )
                  .toList(),
            ),
            if (payload.records.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              pw.Text(
                'Detail Parameter Operator',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...payload.records.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: _detailCard(
                    item,
                    dateTimeFormat,
                    payload.operatorFieldLabel,
                  ),
                ),
              ),
            ],
          ];
        },
      ),
    );

    return doc.save();
  }

  Future<Uint8List> _buildExcelBytes(ReportExportPayload payload) async {
    final excel = Excel.createExcel();

    // 1. RAW DATA SHEET ("Laporan")
    final rawSheet = excel['Laporan'];
    rawSheet.appendRow([
      TextCellValue('Laporan PLN Nusa Daya'),
    ]);
    rawSheet.appendRow([
      TextCellValue('Periode'),
      TextCellValue(payload.periodLabel),
    ]);
    rawSheet.appendRow([
      TextCellValue('Rentang'),
      TextCellValue(payload.dateRangeLabel),
    ]);
    rawSheet.appendRow([
      TextCellValue('Dicetak oleh'),
      TextCellValue(payload.exportedBy),
    ]);
    rawSheet.appendRow(<CellValue>[]);
    rawSheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('Unit'),
      TextCellValue('Operator'),
      TextCellValue('Mesin'),
      TextCellValue('Status Mesin'),
      TextCellValue('Status Data'),
      TextCellValue('Status Laporan'),
      TextCellValue('Beban Mesin (kW)'),
      TextCellValue('Stand KWH (kWh)'),
      TextCellValue('Stand BBM (L)'),
      TextCellValue('Tekanan Oli (bar)'),
      TextCellValue('Temperatur Air (C)'),
      TextCellValue('Phasa R (A)'),
      TextCellValue('Phasa S (A)'),
      TextCellValue('Phasa T (A)'),
      TextCellValue('Tegangan (V)'),
      TextCellValue('Cos Phi'),
      TextCellValue('Frekuensi (Hz)'),
      TextCellValue('Latitude'),
      TextCellValue('Longitude'),
      TextCellValue('Status GPS'),
      TextCellValue(payload.operatorFieldLabel),
      TextCellValue('Catatan Operator'),
      TextCellValue('Warning Abnormal'),
    ]);

    final dateFormat = DateFormat('dd-MM-yyyy HH:mm', 'id_ID');
    for (final item in payload.records) {
      rawSheet.appendRow([
        TextCellValue(dateFormat.format(item.submittedAt)),
        TextCellValue(item.unitName),
        TextCellValue(item.operatorName),
        TextCellValue(item.machineShortLabel),
        TextCellValue(item.machineStatus.label),
        TextCellValue(item.lifecycleStatusLabel),
        TextCellValue(item.reportStatus.name),
        TextCellValue(item.bebanMesin.toStringAsFixed(2)),
        TextCellValue(item.standKwh.toStringAsFixed(2)),
        TextCellValue(item.standBbm.toStringAsFixed(2)),
        TextCellValue(item.tekananOli.toStringAsFixed(2)),
        TextCellValue(item.temperaturAir.toStringAsFixed(2)),
        TextCellValue(item.phasaR.toStringAsFixed(2)),
        TextCellValue(item.phasaS.toStringAsFixed(2)),
        TextCellValue(item.phasaT.toStringAsFixed(2)),
        TextCellValue(item.tegangan.toStringAsFixed(2)),
        TextCellValue(item.cosPhi.toStringAsFixed(2)),
        TextCellValue(item.frequency.toStringAsFixed(2)),
        TextCellValue(item.latitude.toStringAsFixed(6)),
        TextCellValue(item.longitude.toStringAsFixed(6)),
        TextCellValue(item.locationStatus.name),
        TextCellValue(item.fieldCondition),
        TextCellValue(item.notes),
        TextCellValue(item.abnormalNotes),
      ]);
    }

    // 2. GENERATE PIVOT DATA FOR SYSTEM & UNITS (similar to reference format)
    final dateOnlyFormat = DateFormat('yyyy-MM-dd');
    final uniqueDates = payload.records
        .map((r) => dateOnlyFormat.format(r.submittedAt))
        .toSet()
        .toList()
      ..sort();

    final uniqueUnits = payload.records.map((r) => r.unitName).toSet().toList()..sort();

    // Group structure: unitName -> dateString -> hourInt -> sum(bebanMesin)
    final Map<String, Map<String, Map<int, double>>> unitData = {};
    for (final unit in uniqueUnits) {
      unitData[unit] = {};
      for (final date in uniqueDates) {
        unitData[unit]![date] = {for (int h = 0; h < 24; h++) h: 0.0};
      }
    }

    for (final record in payload.records) {
      final dateStr = dateOnlyFormat.format(record.submittedAt);
      final hour = record.submittedAt.hour;
      final unit = record.unitName;
      if (unitData.containsKey(unit) && unitData[unit]!.containsKey(dateStr)) {
        unitData[unit]![dateStr]![hour] = (unitData[unit]![dateStr]![hour] ?? 0.0) + record.bebanMesin;
      }
    }

    // A. Generate Individual Unit Sheets
    for (final unit in uniqueUnits) {
      final safeSheetName = unit.length > 30 ? unit.substring(0, 30) : unit;
      final unitSheet = excel[safeSheetName];

      final List<CellValue> headers = [
        TextCellValue('JAM'),
        for (int h = 0; h < 24; h++) TextCellValue('${h.toString().padLeft(2, '0')}:00'),
        TextCellValue(''),
        TextCellValue('MAX'),
        TextCellValue('MIN'),
      ];
      unitSheet.appendRow(headers);

      for (final date in uniqueDates) {
        final hoursMap = unitData[unit]![date]!;
        final List<double> values = [];
        for (int h = 0; h < 24; h++) {
          values.add(hoursMap[h] ?? 0.0);
        }
        final maxVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
        final minVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);

        final List<CellValue> rowCells = [
          TextCellValue(date),
          for (final val in values) TextCellValue(val.toStringAsFixed(2)),
          TextCellValue(''),
          TextCellValue(maxVal.toStringAsFixed(2)),
          TextCellValue(minVal.toStringAsFixed(2)),
        ];
        unitSheet.appendRow(rowCells);
      }
    }

    // B. Generate TOTAL SISTEM Sheet
    if (uniqueUnits.isNotEmpty) {
      final totalSheet = excel['TOTAL SISTEM'];

      final List<CellValue> headers = [
        TextCellValue('JAM'),
        for (int h = 0; h < 24; h++) TextCellValue('${h.toString().padLeft(2, '0')}:00'),
        TextCellValue(''),
        TextCellValue('MAX'),
        TextCellValue('MIN'),
      ];
      totalSheet.appendRow(headers);

      for (final date in uniqueDates) {
        final List<double> values = List.filled(24, 0.0);
        for (int h = 0; h < 24; h++) {
          double sum = 0.0;
          for (final unit in uniqueUnits) {
            sum += unitData[unit]![date]![h] ?? 0.0;
          }
          values[h] = sum;
        }
        final maxVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
        final minVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);

        final List<CellValue> rowCells = [
          TextCellValue(date),
          for (final val in values) TextCellValue(val.toStringAsFixed(2)),
          TextCellValue(''),
          TextCellValue(maxVal.toStringAsFixed(2)),
          TextCellValue(minVal.toStringAsFixed(2)),
        ];
        totalSheet.appendRow(rowCells);
      }
    }

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? <int>[]);
  }

  pw.Widget _detailCard(
    LogsheetModel item,
    DateFormat dateTimeFormat,
    String operatorFieldLabel,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueGrey200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${item.unitName} • ${item.machineDisplayName}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${dateTimeFormat.format(item.submittedAt)} • ${item.operatorName} • ${item.lifecycleStatusLabel}',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _detailMetric('Beban', '${item.bebanMesin.toStringAsFixed(2)} kW'),
              _detailMetric('Stand KWH', item.standKwh.toStringAsFixed(2)),
              _detailMetric('Stand BBM', '${item.standBbm.toStringAsFixed(2)} L'),
              _detailMetric('Tekanan Oli', '${item.tekananOli.toStringAsFixed(2)} bar'),
              _detailMetric('Temperatur Air', '${item.temperaturAir.toStringAsFixed(2)} C'),
              _detailMetric('Phasa R', '${item.phasaR.toStringAsFixed(2)} A'),
              _detailMetric('Phasa S', '${item.phasaS.toStringAsFixed(2)} A'),
              _detailMetric('Phasa T', '${item.phasaT.toStringAsFixed(2)} A'),
              _detailMetric('Tegangan', '${item.tegangan.toStringAsFixed(2)} V'),
              _detailMetric('Cos Phi', item.cosPhi.toStringAsFixed(2)),
              _detailMetric('Frekuensi', '${item.frequency.toStringAsFixed(2)} Hz'),
              _detailMetric('Status GPS', item.locationStatus.name),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '$operatorFieldLabel: ${item.fieldCondition.isEmpty ? '-' : item.fieldCondition}',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Catatan Operator: ${item.notes.isEmpty ? '-' : item.notes}',
            style: const pw.TextStyle(fontSize: 8),
          ),
          if (item.abnormalNotes.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Warning/Abnormal: ${item.abnormalNotes}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _detailMetric(String label, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7)),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
          ),
        ],
      ),
    );
  }

  String _pdfParameterSummary(LogsheetModel item) {
    return 'Beban ${item.bebanMesin.toStringAsFixed(1)} kW\n'
        'KWH ${item.standKwh.toStringAsFixed(1)} • BBM ${item.standBbm.toStringAsFixed(1)} L\n'
        'Oli ${item.tekananOli.toStringAsFixed(1)} • Air ${item.temperaturAir.toStringAsFixed(1)}\n'
        'R/S/T ${item.phasaR.toStringAsFixed(0)}/${item.phasaS.toStringAsFixed(0)}/${item.phasaT.toStringAsFixed(0)}\n'
        'Teg ${item.tegangan.toStringAsFixed(0)} • Cos ${item.cosPhi.toStringAsFixed(2)} • Hz ${item.frequency.toStringAsFixed(1)}';
  }

  pw.Widget _summaryBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
