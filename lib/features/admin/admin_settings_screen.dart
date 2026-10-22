import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../models/school_settings_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/repository_manager.dart';
import '../../services/seed_data.dart';
import '../../widgets/firebase_status_dialog.dart';

class AdminSettingsScreen extends StatefulWidget {
  final bool isStandalone;
  const AdminSettingsScreen({super.key, this.isStandalone = false});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _attCutoffController = TextEditingController();
  final _diaryPublishController = TextEditingController();
  final _minAttendanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final admin = context.read<AdminProvider>();
    final s = admin.settings ?? SeedData.settings;
    _attCutoffController.text = s.attendanceCutoffTime;
    _diaryPublishController.text = s.diaryPublishTime;
    _minAttendanceController.text = s.minimumAttendancePercentage.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _attCutoffController.dispose();
    _diaryPublishController.dispose();
    _minAttendanceController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final admin = context.read<AdminProvider>();
    final newSettings = SchoolSettings(
      schoolId: admin.settings?.schoolId ?? SchoolConstants.defaultSchoolId,
      attendanceCutoffTime: _attCutoffController.text.trim(),
      diaryPublishTime: _diaryPublishController.text.trim(),
      minimumAttendancePercentage: double.tryParse(_minAttendanceController.text) ?? 75.0,
    );

    final success = await admin.updateSettings(newSettings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(success ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(success ? 'School settings updated successfully.' : 'Failed to update settings.'),
            ],
          ),
          backgroundColor: success ? AppColors.present : AppColors.absent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final repoMgr = context.watch<RepositoryManager>();

    return Scaffold(
      appBar: widget.isStandalone
          ? AppBar(title: Text('System Settings & Cutoffs', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School Info Card
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
                      SchoolConstants.schoolName,
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SchoolConstants.schoolMotto,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.goldAccentDark, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Address: Main Campus, Gulshan Branch • School ID: school_darearqam_01',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 18),

            // Time Cutoffs & Thresholds Form
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
                    'System Cutoffs & Policies',
                    style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _attCutoffController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Attendance Cutoff Time (HH:mm)',
                      hintText: '09:30',
                      prefixIcon: Icon(Icons.alarm_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _diaryPublishController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Diary Auto-Publish Time (HH:mm)',
                      hintText: '14:00',
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _minAttendanceController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Minimum Attendance Percentage (%)',
                      hintText: '75',
                      prefixIcon: Icon(Icons.percent_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_rounded, size: 20),
                      label: Text('Save Cutoff Configuration', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.5)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 18),

            // Backend Database Controls Card
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
                    'Backend Engine & Database Controls',
                    style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: repoMgr.isSupabaseMode ? AppColors.presentLight : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          repoMgr.isSupabaseMode ? Icons.cloud_done_rounded : Icons.offline_bolt_rounded,
                          color: repoMgr.isSupabaseMode ? AppColors.present : Colors.amber.shade900,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              repoMgr.isSupabaseMode ? 'Supabase PostgreSQL Mode' : 'In-Memory Mock Mode',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5),
                            ),
                            Text(
                              repoMgr.isSupabaseMode
                                  ? 'Connected to live Supabase database'
                                  : 'Running on local in-memory prototype engine',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const BackendStatusDialog(),
                            );
                          },
                          icon: const Icon(Icons.info_outline_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Setup Guide', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await repoMgr.seedInitialData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Text(success ? 'Demo data re-seeded successfully!' : 'Re-seeding failed.'),
                                    ],
                                  ),
                                  backgroundColor: success ? AppColors.present : AppColors.absent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.restore_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Re-Seed Data', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: 180.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 18),

            // Sign out
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.absent),
                title: Text(
                  'Sign Out of Principal Portal',
                  style: GoogleFonts.outfit(color: AppColors.absent, fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                onTap: () => auth.logout(),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: 240.ms)
                .slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }
}
