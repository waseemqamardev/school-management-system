import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/diary_provider.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/summary_stat_card.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_diary_screen.dart';
import 'teacher_marks_screen.dart';
import 'teacher_profile_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final assignedClassId = auth.teacherProfile?.assignedClassIds.isNotEmpty == true
          ? auth.teacherProfile!.assignedClassIds.first
          : null;
      context.read<AttendanceProvider>().initializeForClass(assignedClassId);
      context.read<DiaryProvider>().initialize(assignedClassId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      ShellDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Home',
      ),
      ShellDestination(
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check_rounded,
        label: 'Attendance',
      ),
      ShellDestination(
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
        label: 'Diary',
      ),
      ShellDestination(
        icon: Icons.grade_outlined,
        selectedIcon: Icons.grade_rounded,
        label: 'Marks',
      ),
      ShellDestination(
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    Widget body;
    switch (_currentIndex) {
      case 0:
        body = _buildTeacherHome(context);
        break;
      case 1:
        body = const TeacherAttendanceScreen();
        break;
      case 2:
        body = const TeacherDiaryScreen();
        break;
      case 3:
        body = const TeacherMarksScreen();
        break;
      case 4:
        body = const TeacherProfileScreen();
        break;
      default:
        body = _buildTeacherHome(context);
    }

    return ResponsiveShell(
      title: 'Teacher Portal',
      roleBadge: 'Teacher',
      currentIndex: _currentIndex,
      onIndexChanged: (idx) => setState(() => _currentIndex = idx),
      destinations: destinations,
      body: body,
    );
  }

  Widget _buildTeacherHome(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attProvider = context.watch<AttendanceProvider>();
    final diaryProvider = context.watch<DiaryProvider>();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner with Islamic Dua and Emerald Gradient
          RepaintBoundary(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppColors.elevatedShadow,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: -8,
                    child: Text(
                      'رَبِّ زِدْنِي عِلْمًا',
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(22),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Welcome, ${auth.currentUser?.name ?? 'Teacher'}!',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.goldAccent.withAlpha(45),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.goldAccent, width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.goldAccentLight),
                                const SizedBox(width: 4),
                                Text(
                                  'Class 8-A Teacher',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            dateStr,
                            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Assigned: Mathematics, Science • Class 8-A',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 20),

          // Attendance Cutoff Warning Card (if after 9:30 AM and still pending)
          if (attProvider.isPastCutoff)
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
                    child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 26),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Past 9:30 AM Cutoff!',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Today\'s attendance for ${attProvider.selectedClass?.displayName ?? 'Class 8-A'} is still PENDING. Please submit promptly.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.red.shade800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.absent,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Text('Mark Now', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideX(begin: -0.05, end: 0),

          if (attProvider.isPastCutoff) const SizedBox(height: 18),

          // Overview Status Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final crossAxisCount = isWide ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 1.35 : 1.1,
                children: [
                  SummaryStatCard(
                    title: 'Today\'s Attendance',
                    value: attProvider.isSubmitted ? 'Submitted' : 'Pending',
                    icon: attProvider.isSubmitted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                    color: attProvider.isSubmitted ? AppColors.present : Colors.amber.shade800,
                    subtitle: '${attProvider.presentCount}/${attProvider.totalStudents} Present',
                    animationDelayMs: 100,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SummaryStatCard(
                    title: 'Absent Today',
                    value: '${attProvider.absentCount}',
                    icon: Icons.person_off_rounded,
                    color: AppColors.absent,
                    subtitle: 'Alerts active',
                    animationDelayMs: 160,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SummaryStatCard(
                    title: 'Today\'s Diary',
                    value: diaryProvider.isPublished ? 'Published' : '${diaryProvider.completedSubjectsCount}/${diaryProvider.totalSubjects}',
                    icon: Icons.menu_book_rounded,
                    color: diaryProvider.isPublished ? AppColors.present : AppColors.primary,
                    subtitle: diaryProvider.isPublished ? 'Sent to parents' : 'Ready',
                    animationDelayMs: 220,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  SummaryStatCard(
                    title: 'Assigned Classes',
                    value: '${attProvider.classes.length}',
                    icon: Icons.groups_rounded,
                    color: Colors.indigo,
                    subtitle: 'Class 8-A',
                    animationDelayMs: 280,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Quick Action Cards
          Text(
            'Quick Actions',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.fact_check_rounded,
                  label: 'Mark\nAttendance',
                  color: AppColors.primary,
                  delayMs: 320,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Add\nDiary',
                  color: AppColors.goldAccentDark,
                  delayMs: 370,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.grade_rounded,
                  label: 'Enter\nMarks',
                  color: Colors.teal,
                  delayMs: 420,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.people_outline_rounded,
                  label: 'My\nStudents',
                  color: Colors.blueGrey,
                  delayMs: 470,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's Routine / Class 8-A Preview
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Class 8-A Status',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${attProvider.totalStudents} Students Enrolled',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Subject Diary Completion Today:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: diaryProvider.subjects.map((s) {
                    final isDone = diaryProvider.getEntryForSubject(s.subjectId)?.status == 'completed';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.presentLight : AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDone ? AppColors.present.withAlpha(90) : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.schedule_rounded,
                            size: 15,
                            color: isDone ? AppColors.present : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${s.name}: ${isDone ? 'Done' : 'Pending'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDone ? AppColors.present : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int delayMs;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: delayMs.ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}
