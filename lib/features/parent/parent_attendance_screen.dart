import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/parent_provider.dart';
import '../../widgets/attendance_status_chip.dart';

class ParentAttendanceScreen extends StatelessWidget {
  final bool isStandalone;
  const ParentAttendanceScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final child = parentProvider.selectedChild;
    final records = parentProvider.attendanceRecords;
    final percentage = parentProvider.attendancePercentage;
    final isLow = parentProvider.isLowAttendance;

    return Scaffold(
      appBar: isStandalone ? AppBar(title: Text('Attendance Record', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))) : null,
      body: child == null
          ? Center(child: Text('No student linked.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Attendance Percentage Card
                  RepaintBoundary(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLow
                              ? [const Color(0xFFDC2626), const Color(0xFF991B1B)]
                              : [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isLow ? Colors.red.shade300 : AppColors.accentYellow.withAlpha(90),
                          width: 1.5,
                        ),
                        boxShadow: isLow
                            ? [
                                BoxShadow(
                                  color: Colors.red.withAlpha(60),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : AppColors.elevatedShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Attendance',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Holidays excluded • ${records.length} Recorded Days',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLow ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                  // Warning Card if Low Attendance (< 75%)
                  if (isLow) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade300, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.report_problem_rounded, color: Colors.red.shade800, size: 24),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attendance Shortage Alert!',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${child.name}\'s attendance has dropped below 75%. Please ensure regular attendance or contact school administration.',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.red.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: -0.05, end: 0),
                  ],

                  const SizedBox(height: 20),

                  // Legend for Status Chips
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: _LegendItem(label: 'P = Present', color: AppColors.present))),
                        Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: _LegendItem(label: 'A = Absent', color: AppColors.absent))),
                        Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: _LegendItem(label: 'L = Late', color: AppColors.late))),
                        Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: _LegendItem(label: 'LV = Leave', color: AppColors.leave))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Daily Attendance History',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No attendance history available.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: records.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final rec = records[index];
                        final parts = rec.attendanceId.split('_');
                        final dateStr = parts.length > 2 ? parts.sublist(2).join('_') : '';
                        DateTime? date = DateTime.tryParse(dateStr);
                        date ??= rec.updatedAt;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
                            ),
                            title: Text(
                              DateFormat('EEEE, d MMMM yyyy').format(date),
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Updated: ${DateFormat('hh:mm a').format(rec.updatedAt)}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                            trailing: AttendanceStatusChip(
                              status: rec.status,
                              compact: false,
                            ),
                          ),
                        )
                            .animate(delay: (index * 40).ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.05, end: 0);
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
