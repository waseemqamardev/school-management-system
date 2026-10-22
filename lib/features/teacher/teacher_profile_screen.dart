import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/firebase_status_dialog.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(60), width: 3),
                  ),
                ),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.school_rounded, size: 48, color: AppColors.primary),
                ),
              ],
            ),
          )
              .animate()
              .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Teacher',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          Text(
            user?.email ?? '',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Text(
              'Senior Teacher • Dar-e-Arqam School',
              style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: AppColors.primary),
                  title: Text('Institution', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                  subtitle: Text(SchoolConstants.schoolName, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  title: Text('Mobile Phone', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                  subtitle: Text(user?.phone ?? 'Not provided', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.class_outlined, color: AppColors.primary),
                  title: Text('Assigned Class', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                  subtitle: Text('Class 8-A (Class Teacher)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.book_outlined, color: AppColors.primary),
                  title: Text('Teaching Subjects', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                  subtitle: Text('Mathematics, Science', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 100.ms)
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_rounded, color: AppColors.goldAccentDark),
                  title: Text('Supabase Backend Setup', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Check database sync, tables, and seed data', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const BackendStatusDialog(),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.absent),
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.absent),
                  ),
                  onTap: () => auth.logout(),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 180.ms)
              .slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }
}
