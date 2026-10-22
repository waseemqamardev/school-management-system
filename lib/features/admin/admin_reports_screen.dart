import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/student_model.dart';
import '../../providers/admin_provider.dart';

class AdminReportsScreen extends StatefulWidget {
  final bool isStandalone;
  const AdminReportsScreen({super.key, this.isStandalone = false});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<Map<String, dynamic>> _lowAttendanceList = [];
  bool _isLoadingLowAtt = true;

  @override
  void initState() {
    super.initState();
    _loadLowAttendance();
  }

  void _loadLowAttendance() async {
    final admin = context.read<AdminProvider>();
    final list = await admin.getLowAttendanceStudents();
    if (mounted) {
      setState(() {
        _lowAttendanceList = list;
        _isLoadingLowAtt = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final summaries = admin.classSummaries;

    int totalPresent = 0;
    int totalAbsent = 0;
    for (final s in summaries) {
      totalPresent += s.presentCount;
      totalAbsent += s.absentCount;
    }

    return Scaffold(
      appBar: widget.isStandalone
          ? AppBar(title: Text('School Reports & Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Today's Attendance Summary Chart
            RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Attendance Ratio (Live Database Data)',
                      style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 190,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 38,
                                sections: [
                                  PieChartSectionData(
                                    color: AppColors.present,
                                    value: totalPresent > 0 ? totalPresent.toDouble() : 1.0,
                                    title: '$totalPresent',
                                    radius: 48,
                                    titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.absent,
                                    value: totalAbsent > 0 ? totalAbsent.toDouble() : 0.0,
                                    title: '$totalAbsent',
                                    radius: 48,
                                    titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendRow('Present Today', '$totalPresent', AppColors.present),
                                const SizedBox(height: 10),
                                _legendRow('Absent Today', '$totalAbsent', AppColors.absent),
                                const SizedBox(height: 10),
                                _legendRow('Classes Pending', '${admin.attendancePendingClassesCount}', Colors.amber.shade800),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            // 2. Class-Wise Attendance Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class-wise Attendance Breakdown',
                    style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: summaries.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final s = summaries[index];
                      final rate = s.totalStudents > 0
                          ? ((s.presentCount / s.totalStudents) * 100).toStringAsFixed(0)
                          : '0';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.schoolClass.displayName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Text(
                          s.attendanceSubmitted
                              ? 'Present: ${s.presentCount} • Absent: ${s.absentCount} of ${s.totalStudents} enrolled'
                              : 'Attendance Pending for today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: s.attendanceSubmitted ? AppColors.textSecondary : Colors.amber.shade900,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: s.attendanceSubmitted ? AppColors.presentLight : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: s.attendanceSubmitted ? AppColors.present.withAlpha(90) : Colors.amber.shade400,
                            ),
                          ),
                          child: Text(
                            s.attendanceSubmitted ? '$rate% Present' : 'Pending',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: s.attendanceSubmitted ? AppColors.present : Colors.amber.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            // 3. Low Attendance Students (< 75%) Alert Report
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Students with Attendance Under 75%',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.absent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Students requiring principal notice due to low attendance threshold:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingLowAtt)
                    const Center(child: CircularProgressIndicator())
                  else if (_lowAttendanceList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.presentLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.present.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.present, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'All students maintain 75% or higher attendance.',
                            style: GoogleFonts.plusJakartaSans(color: AppColors.present, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _lowAttendanceList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _lowAttendanceList[index];
                        final st = item['student'] as Student;
                        final pct = (item['percentage'] as double).toStringAsFixed(1);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red.shade100,
                                child: Text(st.rollNumber, style: GoogleFonts.outfit(color: Colors.red.shade900, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(st.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text('${item['className']} • ${item['presentDays']}/${item['validDays']} Valid Days Present', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.absent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$pct%',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: 150.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 20),

            // 4. Diary Completion Progress
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Diary Publishing Status',
                    style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  ...summaries.map((s) {
                    final pct = s.totalSubjects > 0 ? (s.completedSubjects / s.totalSubjects) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.schoolClass.displayName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text(
                                s.diaryPublished
                                    ? 'Published to Parents'
                                    : '${s.completedSubjects}/${s.totalSubjects} Subjects Done',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: s.diaryPublished ? AppColors.present : Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: AppColors.backgroundElevated,
                              color: s.diaryPublished ? AppColors.present : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: 200.ms)
                .slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '$label: ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary),
          ),
        ),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12.5, color: color)),
      ],
    );
  }
}
