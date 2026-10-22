import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/parent_provider.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/summary_stat_card.dart';
import '../../widgets/link_child_dialog.dart';
import '../../widgets/scroll_3d_effects.dart';
import '../notifications/notification_center_screen.dart';
import 'parent_diary_screen.dart';
import 'parent_attendance_screen.dart';
import 'parent_results_screen.dart';
import 'parent_profile_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<ParentProvider>().initializeForParent(auth.currentUser!.userId);
        context.read<NotificationProvider>().loadNotifications(auth.currentUser!.userId);
      }
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
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
        label: 'Diary',
      ),
      ShellDestination(
        icon: Icons.calendar_today_outlined,
        selectedIcon: Icons.calendar_today_rounded,
        label: 'Attendance',
      ),
      ShellDestination(
        icon: Icons.military_tech_outlined,
        selectedIcon: Icons.military_tech_rounded,
        label: 'Results',
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
        body = _buildParentHome(context);
        break;
      case 1:
        body = const ParentDiaryScreen();
        break;
      case 2:
        body = const ParentAttendanceScreen();
        break;
      case 3:
        body = const ParentResultsScreen();
        break;
      case 4:
        body = const ParentProfileScreen();
        break;
      default:
        body = _buildParentHome(context);
    }

    return ResponsiveShell(
      title: 'Parent Portal',
      roleBadge: 'Parent (Read-Only)',
      currentIndex: _currentIndex,
      onIndexChanged: (idx) => setState(() => _currentIndex = idx),
      destinations: destinations,
      body: body,
    );
  }

  Widget _buildParentHome(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final selectedChild = parentProvider.selectedChild;
    final children = parentProvider.children;

    if (parentProvider.isLoading && children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (children.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.family_restroom_rounded, size: 54, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(
                'No Student Connected Yet',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your child to your account using their Roll Number and Class to monitor daily attendance, diary, and marks.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const LinkChildDialog(),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text('Connect Your Child', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final todayStr = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        if (auth.currentUser != null) {
          await parentProvider.initializeForParent(auth.currentUser!.userId);
        }
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Time-based Islamic Greeting Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldAccent, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        SchoolConstants.logoAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.school, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SchoolConstants.getDynamicGreeting(userName: auth.currentUser?.name.split(' ').first ?? 'Parent'),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        Text(
                          todayStr,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

            // Child Selector & Link Button Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedChild?.studentId,
                        items: children.map((c) {
                          return DropdownMenuItem(
                            value: c.studentId,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: AssetImage(SchoolConstants.getStudentAvatar(c.name)),
                                  backgroundColor: AppColors.primaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${c.name} (Roll #${c.rollNumber} • Class 8-A)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final match = children.firstWhere((c) => c.studentId == id);
                            parentProvider.selectChild(match);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const LinkChildDialog(),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: AppColors.rippleBlue,
                      highlightColor: AppColors.rippleYellow.withAlpha(40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentYellow.withAlpha(90),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_link_rounded, size: 16, color: AppColors.primaryDark),
                            const SizedBox(width: 3),
                            Text(
                              'Link Child',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -0.1, end: 0),
            const SizedBox(height: 12),

            // 3D Perspective Student Coverflow Carousel
            Student3DCoverflowCarousel(
              children: children,
              selectedChild: selectedChild,
              onChildSelected: (child) {
                parentProvider.selectChild(child);
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 16),

          // Low Attendance Warning Alert if < 75%
          if (parentProvider.isLowAttendance) ...[
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
                    child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 24),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 800.ms),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Low Attendance Warning (${parentProvider.attendancePercentage.toStringAsFixed(1)}%)',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.red.shade900, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Minimum attendance requirement is 75%. Please ensure regular school attendance.',
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
            const SizedBox(height: 16),
          ],

          // Quick Cards Grid: Today's Diary, Attendance, Marks, Notifications
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
                childAspectRatio: isWide ? 1.4 : (constraints.maxWidth < 360 ? 1.05 : 1.15),
                children: [
                  SummaryStatCard(
                    title: 'Today\'s Attendance',
                    value: parentProvider.todayAttendanceStatus ?? 'Pending',
                    icon: Icons.co_present_rounded,
                    color: parentProvider.todayAttendanceStatus == 'absent' ? AppColors.absent : AppColors.primary,
                    subtitle: '${parentProvider.attendancePercentage.toStringAsFixed(0)}% Overall',
                    animationDelayMs: 150,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  SummaryStatCard(
                    title: 'Today\'s Diary',
                    value: parentProvider.todayDiary?.published == true ? 'Published' : 'In Progress',
                    icon: Icons.menu_book_rounded,
                    color: parentProvider.todayDiary?.published == true ? AppColors.primary : AppColors.yellowAccentDark,
                    subtitle: 'Tap to view',
                    animationDelayMs: 200,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  SummaryStatCard(
                    title: 'Academic Score',
                    value: '${parentProvider.averageMarksPercentage.toStringAsFixed(0)}%',
                    icon: Icons.military_tech_rounded,
                    color: AppColors.primaryLight,
                    subtitle: 'Recent test avg',
                    animationDelayMs: 250,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  SummaryStatCard(
                    title: 'Notifications',
                    value: '${notifProvider.unreadCount}',
                    icon: Icons.notifications_active_rounded,
                    color: AppColors.yellowAccentDark,
                    subtitle: 'Unread alerts',
                    animationDelayMs: 300,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          // Today's Diary Teaser Card with 3D Perspective Tilt and Ripple Effect
          Scroll3DItem(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = 1),
                  borderRadius: BorderRadius.circular(18),
                  splashColor: AppColors.rippleBlue,
                  highlightColor: AppColors.rippleYellow.withAlpha(20),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Today\'s School Diary Preview',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Full',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 10),
                  if (parentProvider.todayDiaryEntries.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aaj diary nahi di gayi ya school se abhi publish nahi hui.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...parentProvider.todayDiaryEntries.entries.take(2).map((entry) {
                      String subName = 'Subject';
                      for (final s in parentProvider.classSubjects) {
                        if (s.subjectId == entry.key) {
                          subName = s.name;
                          break;
                        }
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.presentLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, size: 14, color: AppColors.present),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subName,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.value.homework.isNotEmpty ? entry.value.homework : entry.value.classwork,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 350.ms)
        .slideY(begin: 0.05, end: 0),

    const SizedBox(height: 16),

    // Recent Marks Teaser Card with 3D Perspective Tilt & Ripple
    if (parentProvider.latestMark != null)
      Scroll3DItem(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              splashColor: AppColors.rippleBlue,
              highlightColor: AppColors.rippleYellow.withAlpha(20),
              onTap: () => setState(() => _currentIndex = 3),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.grade_rounded, color: AppColors.primary, size: 22),
                ),
                title: Text(
                  'Latest Result: ${parentProvider.latestMark!.examType}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  'Score: ${parentProvider.latestMark!.obtainedMarks.toInt()}/${parentProvider.latestMark!.totalMarks.toInt()} (${parentProvider.latestMark!.percentage.toInt()}%)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.05, end: 0),
        ],
      ),
    ),
  );
}
}
