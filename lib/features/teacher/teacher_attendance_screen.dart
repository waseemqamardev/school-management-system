import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/attendance_status_chip.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final bool isStandalone;
  const TeacherAttendanceScreen({super.key, this.isStandalone = false});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final assignedClassId = auth.teacherProfile?.assignedClassIds.isNotEmpty == true
          ? auth.teacherProfile!.assignedClassIds.first
          : null;
      context.read<AttendanceProvider>().initializeForClass(assignedClassId);
    });
  }

  void _showDatePicker() async {
    final attProvider = context.read<AttendanceProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: attProvider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      attProvider.selectDate(picked);
    }
  }

  void _confirmAndSubmitAttendance() {
    final attProvider = context.read<AttendanceProvider>();
    final auth = context.read<AuthProvider>();
    final isAlreadySubmitted = attProvider.isSubmitted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAlreadySubmitted ? AppColors.primaryContainer : AppColors.goldAccentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAlreadySubmitted ? Icons.update_rounded : Icons.check_circle_rounded,
                color: isAlreadySubmitted ? AppColors.primary : AppColors.goldAccentDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isAlreadySubmitted ? 'Update Attendance?' : 'Submit Attendance?',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAlreadySubmitted
                  ? 'Are you sure you want to update attendance for ${attProvider.selectedClass?.displayName} (${attProvider.selectedDateFormatted})?'
                  : 'Are you sure you want to submit today\'s attendance for ${attProvider.selectedClass?.displayName}?',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Students:', style: GoogleFonts.plusJakartaSans(fontSize: 12.5)),
                      Text('${attProvider.totalStudents}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Present:', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.present, fontWeight: FontWeight.w600)),
                      Text('${attProvider.presentCount}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.present, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Absent:', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.absent, fontWeight: FontWeight.w600)),
                      Text('${attProvider.absentCount}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.absent, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            if (attProvider.absentCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.absent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Parents of ${attProvider.absentCount} absent student(s) will be automatically notified.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.absent, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final teacherId = auth.currentUser?.userId ?? 'teacher_01';
              final success = await attProvider.submitAttendance(teacherId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          const Text('Attendance Submitted Successfully!'),
                        ],
                      ),
                      backgroundColor: AppColors.present,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(attProvider.errorMessage ?? 'Submission failed.'),
                      backgroundColor: AppColors.absent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            child: Text(isAlreadySubmitted ? 'Update Attendance' : 'SUBMIT ATTENDANCE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attProvider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: widget.isStandalone
          ? AppBar(title: Text('Mark Attendance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          : null,
      body: attProvider.isLoading && attProvider.students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Cutoff Alert Banner if pending past 9:30 AM
                if (attProvider.isPastCutoff)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade900, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attendance Cutoff Warning: It is past 9:30 AM and attendance is still pending!',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Top Controls: Class selector & Date picker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      // Class Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: attProvider.selectedClass?.classId,
                          decoration: InputDecoration(
                            labelText: 'Class',
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: attProvider.classes.map((c) {
                            return DropdownMenuItem(
                              value: c.classId,
                              child: Text(c.displayName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final sel = attProvider.classes.firstWhere((c) => c.classId == val);
                              attProvider.selectClass(sel);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date Selector
                      Expanded(
                        child: InkWell(
                          onTap: _showDatePicker,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(attProvider.selectedDate),
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Live Summary Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    border: Border(bottom: BorderSide(color: AppColors.border.withAlpha(80))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryPill(label: 'Total', count: attProvider.totalStudents, color: AppColors.textPrimary),
                      _SummaryPill(label: 'Present', count: attProvider.presentCount, color: AppColors.present),
                      _SummaryPill(label: 'Absent', count: attProvider.absentCount, color: AppColors.absent),
                      _SummaryPill(label: 'Late', count: attProvider.lateCount, color: AppColors.late),
                      _SummaryPill(label: 'Leave', count: attProvider.leaveCount, color: AppColors.leave),
                    ],
                  ),
                ),

                // Status Banner: Submitted vs Pending
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: attProvider.isSubmitted ? AppColors.presentLight : Colors.amber.shade50,
                    border: Border(
                      bottom: BorderSide(
                        color: attProvider.isSubmitted ? AppColors.present.withAlpha(60) : Colors.amber.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        attProvider.isSubmitted ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                        size: 17,
                        color: attProvider.isSubmitted ? AppColors.present : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        attProvider.isSubmitted
                            ? 'Attendance Status: SUBMITTED (Editable)'
                            : 'Attendance Status: PENDING (Press Submit to complete)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: attProvider.isSubmitted ? AppColors.present : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

                // Students List
                Expanded(
                  child: attProvider.students.isEmpty
                      ? Center(child: Text('No students found for this class.', style: GoogleFonts.plusJakartaSans()))
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: attProvider.students.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = attProvider.students[index];
                            final currentStatus = attProvider.studentStatusMap[student.studentId] ?? 'present';

                            return RepaintBoundary(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: currentStatus == 'absent'
                                        ? AppColors.absent.withAlpha(100)
                                        : AppColors.border,
                                    width: currentStatus == 'absent' ? 1.5 : 1,
                                  ),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Student Avatar with Image
                                        CircleAvatar(
                                          backgroundColor: AppColors.primaryContainer,
                                          backgroundImage: AssetImage(SchoolConstants.getStudentAvatar(student.name)),
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.name,
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                'Roll #${student.rollNumber} • ${attProvider.selectedClass?.displayName}',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AttendanceStatusChip(
                                          status: currentStatus,
                                          compact: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(height: 1, color: AppColors.border),
                                    const SizedBox(height: 10),
                                    // Status Buttons: Present, Absent, Late, Leave
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: _StatusSelectButton(
                                              label: 'Present',
                                              statusKey: 'present',
                                              color: AppColors.present,
                                              isSelected: currentStatus == 'present',
                                              onTap: () => attProvider.setStudentStatus(student.studentId, 'present'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: _StatusSelectButton(
                                              label: 'Absent',
                                              statusKey: 'absent',
                                              color: AppColors.absent,
                                              isSelected: currentStatus == 'absent',
                                              onTap: () => attProvider.setStudentStatus(student.studentId, 'absent'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: _StatusSelectButton(
                                              label: 'Late',
                                              statusKey: 'late',
                                              color: AppColors.late,
                                              isSelected: currentStatus == 'late',
                                              onTap: () => attProvider.setStudentStatus(student.studentId, 'late'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: _StatusSelectButton(
                                              label: 'Leave',
                                              statusKey: 'leave',
                                              color: AppColors.leave,
                                              isSelected: currentStatus == 'leave',
                                              onTap: () => attProvider.setStudentStatus(student.studentId, 'leave'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate(delay: (index * 25).ms)
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.05, end: 0);
                          },
                        ),
                ),

                // Bottom Action Bar: SUBMIT ATTENDANCE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(top: BorderSide(color: AppColors.border)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${attProvider.presentCount} Present • ${attProvider.absentCount} Absent',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                attProvider.isSubmitted ? 'Already Submitted (Editable)' : 'Pending Submission',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: attProvider.isSubmitted ? AppColors.present : Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: attProvider.isLoading ? null : _confirmAndSubmitAttendance,
                          icon: Icon(
                            attProvider.isSubmitted ? Icons.update_rounded : Icons.check_circle_rounded,
                            size: 17,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              attProvider.isSubmitted ? 'UPDATE' : 'SUBMIT',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: attProvider.isSubmitted ? AppColors.primaryLight : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusSelectButton extends StatelessWidget {
  final String label;
  final String statusKey;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusSelectButton({
    required this.label,
    required this.statusKey,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(60),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
