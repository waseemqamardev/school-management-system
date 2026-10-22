import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../services/repository_manager.dart';

typedef FirebaseStatusDialog = BackendStatusDialog;

class BackendStatusDialog extends StatelessWidget {
  const BackendStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final repoMgr = context.watch<RepositoryManager>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storage_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            'Supabase Backend Setup',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: repoMgr.isUsingMock ? Colors.amber.shade50 : AppColors.presentLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: repoMgr.isUsingMock ? Colors.amber.shade400 : AppColors.present.withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    repoMgr.isUsingMock ? Icons.info_outline_rounded : Icons.check_circle_rounded,
                    color: repoMgr.isUsingMock ? Colors.amber.shade800 : AppColors.present,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      repoMgr.backendStatusMessage,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: repoMgr.isUsingMock ? Colors.amber.shade900 : Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How to connect your Supabase project:',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            const SizedBox(height: 10),
            _codeStep(
              step: '1',
              title: 'Create a free project at supabase.com',
              command: 'Sign in to https://supabase.com and click "New Project"',
            ),
            _codeStep(
              step: '2',
              title: 'Run SQL Schema in Supabase SQL Editor',
              command: 'Open SQL Editor in Supabase, copy-paste the contents of "supabase_schema.sql" from this project, and click RUN.',
            ),
            _codeStep(
              step: '3',
              title: 'Copy Project URL & Anon Key',
              command: 'Go to Project Settings -> API and copy:\n- Project URL\n- anon / public key',
            ),
            _codeStep(
              step: '4',
              title: 'Paste into supabase_config.dart',
              command: 'Open "lib/core/supabase/supabase_config.dart" and paste:\nsupabaseUrl = "https://your-id.supabase.co"\nsupabaseAnonKey = "your-anon-key"',
            ),
            const SizedBox(height: 14),
            Text(
              'Quick Actions for Testing:',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final success = await repoMgr.seedInitialData();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(success ? 'Demo data seeded into current repository!' : 'Seed failed.'),
                            ],
                          ),
                          backgroundColor: success ? AppColors.present : AppColors.absent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restore_page_rounded, size: 16),
                  label: Text('Seed Demo Data', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _codeStep({required String step, required String title, required String command}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.primary,
            child: Text(step, style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    command,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
