import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';

class AdminHolidaysScreen extends StatelessWidget {
  final bool isStandalone;
  const AdminHolidaysScreen({super.key, this.isStandalone = false});

  void _showAddHolidayDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldAccentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.celebration_rounded, color: AppColors.goldAccentDark, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Add School Holiday', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Holiday Title (e.g. Eid Holiday, 14 August)',
                  prefixIcon: Icon(Icons.celebration_outlined),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 60)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
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
                            DateFormat('dd MMMM yyyy').format(selectedDate),
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        'Change',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Note: School attendance is not required on holiday dates and holidays do not penalize student attendance percentage.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
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
                if (titleCtrl.text.trim().isEmpty) return;
                final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                await context.read<AdminProvider>().addHoliday(dateStr, titleCtrl.text.trim());
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add Holiday'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final holidays = admin.holidays;

    return Scaffold(
      appBar: isStandalone ? AppBar(title: Text('Manage School Holidays', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHolidayDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Holiday', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.backgroundElevated,
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Holiday dates are automatically excluded from student absence calculations and valid school days.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: holidays.isEmpty
                ? Center(
                    child: Text(
                      'No holidays added yet.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: holidays.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final h = holidays[index];
                      DateTime? date = DateTime.tryParse(h.date);
                      final displayDate = date != null ? DateFormat('EEEE, d MMMM yyyy').format(date) : h.date;

                      return RepaintBoundary(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.goldAccentLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.beach_access_rounded, color: AppColors.goldAccentDark, size: 22),
                            ),
                            title: Text(
                              h.title,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            subtitle: Text(
                              displayDate,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.absent),
                              onPressed: () => admin.deleteHoliday(h.holidayId),
                            ),
                          ),
                        ),
                      )
                          .animate(delay: (index * 40).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
