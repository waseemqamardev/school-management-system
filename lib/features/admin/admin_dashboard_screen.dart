import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/summary_stat_card.dart';
import 'admin_management_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_holidays_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      ShellDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      ShellDestination(
        icon: Icons.manage_accounts_outlined,
        selectedIcon: Icons.manage_accounts_rounded,
        label: 'Manage CRUD',
      ),
      ShellDestination(
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
        label: 'Reports',
      ),
      ShellDestination(
        icon: Icons.celebration_outlined,
        selectedIcon: Icons.celebration_rounded,
        label: 'Holidays',
      ),
      ShellDestination(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: 'Settings',
      ),
    ];

    Widget body;
    switch (_currentIndex) {
      case 0:
        body = _buildAdminOverview(context);
        break;
      case 1:
        body = const AdminManagementScreen();
        break;
      case 2:
        body = const AdminReportsScreen();
        break;
      case 3:
        body = const AdminHolidaysScreen();
        break;
      case 4:
        body = const AdminSettingsScreen();
        break;
      default:
        body = _buildAdminOverview(context);
    }

    return ResponsiveShell(
      title: 'Principal Administration',
      roleBadge: 'Admin',
      currentIndex: _currentIndex,
      onIndexChanged: (idx) => setState(() => _currentIndex = idx),
      destinations: destinations,
      body: body,
    );
  }

  Widget _buildAdminOverview(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final summaries = admin.classSummaries;
    final now = DateTime.now();
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(now);

    final isPastCutoff = now.hour > 9 || (now.hour == 9 && now.minute >= 30);
    final hasPendingAttendance = admin.attendancePendingClassesCount > 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Welcome Banner
          RepaintBoundary(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                      'دَارُ الأَرْقَمِ',
                      style: GoogleFonts.amiri(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(20),
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
                              'Welcome, ${auth.currentUser?.name ?? 'Principal'}!',
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
                                const Icon(Icons.shield_rounded, size: 14, color: AppColors.goldAccentLight),
                                const SizedBox(width: 4),
                                Text(
                                  'MAIN CAMPUS',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        todayFormatted,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
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

          // Attendance Pending Cutoff Warning Card
          if (isPastCutoff && hasPendingAttendance) ...[
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
                    child: Icon(Icons.access_time_filled_rounded, color: Colors.red.shade800, size: 26),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Cutoff Passed (9:30 AM)',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.red.shade900, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${admin.attendancePendingClassesCount} class(es) still have PENDING attendance for today. Immediate teacher follow-up required.',
                          style: GoogleFonts.plusJakartaSans(color: Colors.red.shade800, fontSize: 12),
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
            const SizedBox(height: 18),
          ],

          // Summary Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final isTablet = constraints.maxWidth >= 600;
              final crossAxisCount = isWide ? 4 : (isTablet ? 3 : 2);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 1.35 : (isTablet ? 1.2 : 1.1),
                children: [
                  SummaryStatCard(
                    title: 'Total Students',
                    value: '${admin.totalStudentsCount}',
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                    subtitle: 'Enrolled',
                    animationDelayMs: 100,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SummaryStatCard(
                    title: 'Total Teachers',
                    value: '${admin.totalTeachersCount}',
                    icon: Icons.person_search_rounded,
                    color: Colors.teal.shade700,
                    subtitle: 'Active Staff',
                    animationDelayMs: 150,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SummaryStatCard(
                    title: 'Total Classes',
                    value: '${admin.totalClassesCount}',
                    icon: Icons.meeting_room_rounded,
                    color: Colors.indigo,
                    subtitle: 'Sections',
                    animationDelayMs: 200,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SummaryStatCard(
                    title: 'Absent Today',
                    value: '${admin.totalAbsentToday}',
                    icon: Icons.person_off_rounded,
                    color: AppColors.absent,
                    subtitle: 'Alerts sent',
                    animationDelayMs: 250,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  SummaryStatCard(
                    title: 'Attendance Pending',
                    value: '${admin.attendancePendingClassesCount}',
                    icon: Icons.pending_actions_rounded,
                    color: admin.attendancePendingClassesCount > 0 ? Colors.amber.shade800 : AppColors.present,
                    subtitle: 'Classes pending',
                    animationDelayMs: 300,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  SummaryStatCard(
                    title: 'Diary Published',
                    value: '${admin.diaryPublishedClassesCount}',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.present,
                    subtitle: 'Classes live',
                    animationDelayMs: 350,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  SummaryStatCard(
                    title: 'Diary Pending',
                    value: '${admin.diaryPendingClassesCount}',
                    icon: Icons.hourglass_bottom_rounded,
                    color: Colors.deepOrange,
                    subtitle: 'In progress',
                    animationDelayMs: 400,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  SummaryStatCard(
                    title: 'School Holidays',
                    value: '${admin.holidays.length}',
                    icon: Icons.beach_access_rounded,
                    color: AppColors.goldAccentDark,
                    subtitle: 'Scheduled',
                    animationDelayMs: 450,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Today's Overview by Class
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Class-wise Overview',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                tooltip: 'Refresh Overview',
                onPressed: () => admin.loadDashboard(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (summaries.isEmpty)
            Center(
              child: Text(
                'No classes found.',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summaries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = summaries[index];
                final isAttSubmitted = s.attendanceSubmitted;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: !isAttSubmitted && isPastCutoff ? Colors.red.shade300 : AppColors.border,
                      width: !isAttSubmitted && isPastCutoff ? 1.5 : 1,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                radius: 18,
                                child: const Icon(Icons.class_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                s.schoolClass.displayName,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAttSubmitted ? AppColors.presentLight : AppColors.pendingLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAttSubmitted ? AppColors.present : Colors.amber.shade700,
                              ),
                            ),
                            child: Text(
                              isAttSubmitted ? 'Attendance: Submitted' : 'Attendance: PENDING',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isAttSubmitted ? AppColors.present : Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildMiniStat(
                            'Students',
                            '${s.totalStudents}',
                            Icons.groups_rounded,
                            AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          _buildMiniStat(
                            'Present',
                            '${s.presentCount}',
                            Icons.check_circle_rounded,
                            AppColors.present,
                          ),
                          const SizedBox(width: 10),
                          _buildMiniStat(
                            'Absent',
                            '${s.absentCount}',
                            Icons.cancel_rounded,
                            AppColors.absent,
                          ),
                          const SizedBox(width: 10),
                          _buildMiniStat(
                            'Diary',
                            s.diaryPublished ? 'Published' : 'Pending',
                            Icons.menu_book_rounded,
                            s.diaryPublished ? AppColors.present : Colors.deepOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate(delay: (index * 80).ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.05, end: 0);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13, color: color),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
