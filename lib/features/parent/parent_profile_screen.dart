import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parent_provider.dart';
import '../../widgets/firebase_status_dialog.dart';
import '../../widgets/link_child_dialog.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final parentProvider = context.watch<ParentProvider>();
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
                    border: Border.all(color: AppColors.goldAccent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(SchoolConstants.avatarBoyAsset),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Parent',
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
              'Guardian / Parent • Read-Only Access',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Linked Students (${parentProvider.children.length})',
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const LinkChildDialog(),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text('Connect Child', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                if (parentProvider.children.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: Text('No students linked yet.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...parentProvider.children.map((child) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: AssetImage(SchoolConstants.getStudentAvatar(child.name)),
                        radius: 22,
                      ),
                      title: Text(child.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ID: ${child.linkCode}',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Roll #${child.rollNumber} • Class 8-A', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.link_off_rounded, size: 20, color: AppColors.textMuted),
                        tooltip: 'Unlink Student',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Text('Unlink ${child.name}?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              content: Text('Are you sure you want to disconnect this student from your parent portal?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.absent),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    if (user != null) {
                                      await parentProvider.unlinkChild(
                                        parentUserId: user.userId,
                                        studentId: child.studentId,
                                      );
                                    }
                                  },
                                  child: const Text('Unlink'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.school_outlined, color: AppColors.primary),
                  title: Text('Institution', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                  subtitle: Text(SchoolConstants.schoolName, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  title: Text('Registered Mobile', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                  subtitle: Text(user?.phone ?? 'Not provided', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
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
                  leading: const Icon(Icons.dns_rounded, color: AppColors.primary),
                  title: Text('Supabase / Backend Engine', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Check active backend and live database sync', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
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
