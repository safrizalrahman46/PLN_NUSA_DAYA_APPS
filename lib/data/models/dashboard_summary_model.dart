class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.todayReports,
    required this.pendingSync,
    required this.successReports,
    required this.abnormalReports,
    required this.totalUnits,
    required this.totalOperators,
    required this.lateOperators,
    required this.nextReportAt,
  });

  final int todayReports;
  final int pendingSync;
  final int successReports;
  final int abnormalReports;
  final int totalUnits;
  final int totalOperators;
  final int lateOperators;
  final DateTime nextReportAt;
}
