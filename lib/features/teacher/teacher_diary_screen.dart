import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diary_provider.dart';

class TeacherDiaryScreen extends StatefulWidget {
  final bool isStandalone;
  const TeacherDiaryScreen({super.key, this.isStandalone = false});

  @override
  State<TeacherDiaryScreen> createState() => _TeacherDiaryScreenState();
}

class _TeacherDiaryScreenState extends State<TeacherDiaryScreen> {
  final _classworkController = TextEditingController();
  final _homeworkController = TextEditingController();
  final _testInfoController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final assignedClassId = auth.teacherProfile?.assignedClassIds.isNotEmpty == true
          ? auth.teacherProfile!.assignedClassIds.first
          : null;
      context.read<DiaryProvider>().initialize(assignedClassId).then((_) {
        _populateFieldsForSelectedSubject();
      });
    });
  }

  @override
  void dispose() {
    _classworkController.dispose();
    _homeworkController.dispose();
    _testInfoController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _populateFieldsForSelectedSubject() {
    final diaryProvider = context.read<DiaryProvider>();
    if (diaryProvider.selectedSubject != null) {
      final entry = diaryProvider.getEntryForSubject(diaryProvider.selectedSubject!.subjectId);
      _classworkController.text = entry?.classwork ?? '';
      _homeworkController.text = entry?.homework ?? '';
      _testInfoController.text = entry?.testInfo ?? '';
      _instructionsController.text = entry?.instructions ?? '';
    } else {
      _classworkController.clear();
      _homeworkController.clear();
      _testInfoController.clear();
      _instructionsController.clear();
    }
  }

  void _showDatePicker() async {
    final diaryProvider = context.read<DiaryProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: diaryProvider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      diaryProvider.selectDate(picked);
      _populateFieldsForSelectedSubject();
    }
  }

  void _saveEntry(bool isDone) async {
    final diaryProvider = context.read<DiaryProvider>();
    final auth = context.read<AuthProvider>();
    if (diaryProvider.selectedSubject == null) return;

    final teacherId = auth.currentUser?.userId ?? 'teacher_01';
    final success = await diaryProvider.saveSubjectEntry(
      subjectId: diaryProvider.selectedSubject!.subjectId,
      teacherId: teacherId,
      homework: _homeworkController.text,
      classwork: _classworkController.text,
      testInfo: _testInfoController.text,
      instructions: _instructionsController.text,
      isDone: isDone,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(isDone ? Icons.check_circle_rounded : Icons.save_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isDone
                        ? '${diaryProvider.selectedSubject!.name} diary marked as Completed!'
                        : '${diaryProvider.selectedSubject!.name} diary saved as Draft.',
                  ),
                ),
              ],
            ),
            backgroundColor: isDone ? AppColors.present : Colors.blueGrey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(diaryProvider.errorMessage ?? 'Error saving diary entry.'),
            backgroundColor: AppColors.absent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _confirmAndPublishDiary() {
    final diaryProvider = context.read<DiaryProvider>();
    final auth = context.read<AuthProvider>();
    final pendingCount = diaryProvider.pendingSubjectsCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Publish Class Diary?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publishing diary for ${diaryProvider.selectedClass?.displayName} on ${diaryProvider.selectedDateFormatted}.',
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
                      Text('Total Subjects:', style: GoogleFonts.plusJakartaSans(fontSize: 12.5)),
                      Text('${diaryProvider.totalSubjects}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Completed:', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.present, fontWeight: FontWeight.w600)),
                      Text('${diaryProvider.completedSubjectsCount}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.present, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pending:', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: pendingCount > 0 ? AppColors.late : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      Text('$pendingCount', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: pendingCount > 0 ? AppColors.late : AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pending subjects will display "Aaj diary nahi di gayi." to parents. Publish anyway?',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                'All subjects are completed! All parents of this class will receive a single notification.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.present, fontWeight: FontWeight.w600),
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
              final success = await diaryProvider.publishClassDiary(teacherId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          const Expanded(child: Text('Class Diary Published! Notification sent to all parents.')),
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
                      content: Text(diaryProvider.errorMessage ?? 'Publish failed.'),
                      backgroundColor: AppColors.absent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            child: const Text('PUBLISH CLASS DIARY'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();

    return Scaffold(
      appBar: widget.isStandalone
          ? AppBar(title: Text('Add Diary', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          : null,
      body: diaryProvider.isLoading && diaryProvider.subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Controls: Class and Date
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: diaryProvider.selectedClass?.classId,
                          decoration: InputDecoration(
                            labelText: 'Class',
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: diaryProvider.classes.map((c) {
                            return DropdownMenuItem(
                              value: c.classId,
                              child: Text(c.displayName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final sel = diaryProvider.classes.firstWhere((c) => c.classId == val);
                              diaryProvider.selectClass(sel);
                              _populateFieldsForSelectedSubject();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                      DateFormat('dd MMM yyyy').format(diaryProvider.selectedDate),
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

                // Diary Status & Publish Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: diaryProvider.isPublished ? AppColors.presentLight : AppColors.backgroundElevated,
                    border: const Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diaryProvider.isPublished ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                        size: 20,
                        color: diaryProvider.isPublished ? AppColors.present : AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          diaryProvider.isPublished
                              ? 'Diary Published to Parents'
                              : 'Progress: ${diaryProvider.completedSubjectsCount}/${diaryProvider.totalSubjects} Subjects Done',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: diaryProvider.isPublished ? AppColors.present : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: diaryProvider.isPublished ? null : _confirmAndPublishDiary,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor: AppColors.primary,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            diaryProvider.isPublished ? 'Published' : 'PUBLISH',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subjects Selector Horizontal Chips
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: diaryProvider.subjects.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final subj = diaryProvider.subjects[index];
                      final isSelected = diaryProvider.selectedSubject?.subjectId == subj.subjectId;
                      final entry = diaryProvider.getEntryForSubject(subj.subjectId);
                      final isCompleted = entry?.status == 'completed';

                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : (isCompleted ? AppColors.present : Colors.grey),
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(subj.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Text(
                              isCompleted ? '(Done)' : '(Pending)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white70
                                    : (isCompleted ? AppColors.present : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        onSelected: (selected) {
                          diaryProvider.selectSubject(subj);
                          _populateFieldsForSelectedSubject();
                        },
                      );
                    },
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diaryProvider.selectedSubject != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${diaryProvider.selectedSubject!.name} Diary Entry',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: diaryProvider.getEntryForSubject(diaryProvider.selectedSubject!.subjectId)?.status == 'completed'
                                      ? AppColors.presentLight
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: diaryProvider.getEntryForSubject(diaryProvider.selectedSubject!.subjectId)?.status == 'completed'
                                        ? AppColors.present.withAlpha(80)
                                        : Colors.amber.shade400,
                                  ),
                                ),
                                child: Text(
                                  diaryProvider.getEntryForSubject(diaryProvider.selectedSubject!.subjectId)?.status == 'completed'
                                      ? 'Status: Completed'
                                      : 'Status: Pending / Draft',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: diaryProvider.getEntryForSubject(diaryProvider.selectedSubject!.subjectId)?.status == 'completed'
                                        ? AppColors.present
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Classwork
                          TextFormField(
                            controller: _classworkController,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(
                              labelText: 'Classwork',
                              hintText: 'e.g. Chapter 4 Exercise 4.1 Q1-Q3 solved in class.',
                              prefixIcon: Icon(Icons.menu_book_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Homework
                          TextFormField(
                            controller: _homeworkController,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(
                              labelText: 'Homework',
                              hintText: 'e.g. Solve Q4 & Q5 on neat notebook.',
                              prefixIcon: Icon(Icons.home_work_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Upcoming Test
                          TextFormField(
                            controller: _testInfoController,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(
                              labelText: 'Upcoming Test',
                              hintText: 'e.g. Chapter 4 Diagnostic Quiz on Friday.',
                              prefixIcon: Icon(Icons.assignment_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Instructions
                          TextFormField(
                            controller: _instructionsController,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                            decoration: const InputDecoration(
                              labelText: 'Special Instructions',
                              hintText: 'e.g. Bring geometry box and graph copy.',
                              prefixIcon: Icon(Icons.info_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Action Buttons: Save Draft & Done
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: diaryProvider.isLoading ? null : () => _saveEntry(false),
                                  icon: const Icon(Icons.save_rounded, size: 18),
                                  label: Text('Save Draft', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: diaryProvider.isLoading ? null : () => _saveEntry(true),
                                  icon: const Icon(Icons.done_all_rounded, size: 18),
                                  label: Text('Done (Complete)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
                        ] else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Please select a subject to enter diary.',
                                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                              ),
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
