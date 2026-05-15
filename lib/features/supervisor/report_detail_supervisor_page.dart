import 'package:flutter/material.dart';

import '../../data/models/logsheet_model.dart';
import '../history/logsheet_detail_page.dart';

class ReportDetailSupervisorPage extends StatelessWidget {
  const ReportDetailSupervisorPage({super.key, required this.logsheet});

  final LogsheetModel logsheet;

  @override
  Widget build(BuildContext context) {
    return LogsheetDetailPage(
      logsheet: logsheet,
      title: 'Detail Laporan Supervisor',
    );
  }
}
