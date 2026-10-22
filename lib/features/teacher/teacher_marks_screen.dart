import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../models/student_model.dart';
import '../../models/subject_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marks_provider.dart';

class TeacherMarksScreen extends StatefulWidget {
  final bool isStandalone;
  const TeacherMarksScreen({super.key, this.isStandalone = false});

  @override
  State<TeacherMarksScreen> createState() => _TeacherMarksScreenState();
}

class _TeacherMarksScreenState extends State<TeacherMarksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _obtainedMarksController = TextEditingController();
  final _totalMarksController = TextEditingController(text: '20');
  final _feedbackController = TextEditingController();
  String _selectedExamType = 'Weekly Test';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final assignedClassId = auth.teacherProfile?.assignedClassIds.isNotEmpty == true
          ? auth.teacherProfile!.assignedClassIds.first
          : null;
      context.read<MarksProvider>().initialize(assignedClassId);
    });
  }

  @override
  void dispose() {
    _obtainedMarksController.dispose();
    _totalMarksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _saveMarks() async {
    if (!_formKey.currentState!.validate()) return;
    final marksProvider = context.read<MarksProvider>();
    final auth = context.read<AuthProvider>();

    if (marksProvider.selectedStudent == null ||
        marksProvider.selectedClass == null ||
        marksProvider.selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class, student, and subject.')),
      );
      return;
    }

    final obtained = double.tryParse(_obtainedMarksController.text) ?? 0.0;
    final total = double.tryParse(_totalMarksController.text) ?? 100.0;
    final teacherId = auth.currentUser?.userId ?? 'teacher_01';

    final success = await marksProvider.saveMark(
      studentId: marksProvider.selectedStudent!.studentId,
      classId: marksProvider.selectedClass!.classId,
      subjectId: marksProvider.selectedSubject!.subjectId,
      examType: _selectedExamType,
      obtainedMarks: obtained,
      totalMarks: total,
      feedback: _feedbackController.text,
      teacherUserId: teacherId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Marks saved and report notification sent to ${marksProvider.selectedStudent!.name}\'s parent!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.present,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _obtainedMarksController.clear();
        _feedbackController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(marksProvider.errorMessage ?? 'Error saving marks.'),
            backgroundColor: AppColors.absent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final marksProvider = context.watch<MarksProvider>();

    return Scaffold(
      appBar: widget.isStandalone
          ? AppBar(title: Text('Enter Marks', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          : null,
      body: marksProvider.isLoading && marksProvider.classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepaintBoundary(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.cardShadow,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Student Assessment Marks',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Class & Subject Row
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: marksProvider.selectedClass?.classId,
                                    decoration: InputDecoration(
                                      labelText: 'Class',
                                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                                    ),
                                    items: marksProvider.classes.map((c) {
                                      return DropdownMenuItem(
                                        value: c.classId,
                                        child: Text(c.displayName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        final sel = marksProvider.classes.firstWhere((c) => c.classId == val);
                                        marksProvider.selectClass(sel);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: marksProvider.selectedSubject?.subjectId,
                                    decoration: InputDecoration(
                                      labelText: 'Subject',
                                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                                    ),
                                    items: marksProvider.subjects.map((s) {
                                      return DropdownMenuItem(
                                        value: s.subjectId,
                                        child: Text(s.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        final sel = marksProvider.subjects.firstWhere((s) => s.subjectId == val);
                                        marksProvider.selectSubject(sel);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Student & Assessment Type Row
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: marksProvider.selectedStudent?.studentId,
                                    decoration: InputDecoration(
                                      labelText: 'Student',
                                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                                    ),
                                    items: marksProvider.students.map((st) {
                                      return DropdownMenuItem(
                                        value: st.studentId,
                                        child: Text('${st.rollNumber}. ${st.name}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        final sel = marksProvider.students.firstWhere((s) => s.studentId == val);
                                        marksProvider.selectStudent(sel);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: _selectedExamType,
                                    decoration: InputDecoration(
                                      labelText: 'Assessment Type',
                                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                                    ),
                                    items: SchoolConstants.assessmentTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedExamType = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Obtained & Total Marks
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _obtainedMarksController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                    decoration: const InputDecoration(
                                      labelText: 'Obtained Marks',
                                      prefixIcon: Icon(Icons.star_outline_rounded),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final num = double.tryParse(val);
                                      if (num == null || num < 0) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _totalMarksController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                    decoration: const InputDecoration(
                                      labelText: 'Total Marks',
                                      prefixIcon: Icon(Icons.pin_outlined),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final num = double.tryParse(val);
                                      if (num == null || num <= 0) {
                                        return 'Must be > 0';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Feedback
                            TextFormField(
                              controller: _feedbackController,
                              maxLines: 2,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                              decoration: const InputDecoration(
                                labelText: 'Teacher Feedback',
                                hintText: 'e.g. Good progress. Needs more practice with fractions.',
                                prefixIcon: Icon(Icons.comment_outlined),
                              ),
                            ),
                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: marksProvider.isLoading ? null : _saveMarks,
                                icon: const Icon(Icons.save_rounded, size: 20),
                                label: Text(
                                  'Save Marks & Notify Parent',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 24),
                  Text(
                    'Recent Class Marks History',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (marksProvider.classMarks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No marks recorded for this class yet.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: marksProvider.classMarks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final mark = marksProvider.classMarks[index];
                        final student = marksProvider.students.firstWhere(
                          (s) => s.studentId == mark.studentId,
                          orElse: () => Student(studentId: '', name: 'Student', rollNumber: '-', classId: '', parentIds: []),
                        );
                        final subject = marksProvider.subjects.firstWhere(
                          (s) => s.subjectId == mark.subjectId,
                          orElse: () => Subject(subjectId: '', name: 'Subject', classId: '', teacherId: ''),
                        );

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                '${mark.percentage.toInt()}%',
                                style: GoogleFonts.outfit(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            title: Text(
                              '${student.name} • ${subject.name}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  '${mark.examType}: ${mark.obtainedMarks.toInt()}/${mark.totalMarks.toInt()} marks • ${DateFormat('dd MMM yyyy').format(mark.createdAt)}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                if (mark.feedback.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${mark.feedback}"',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                            .animate(delay: (index * 40).ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.05, end: 0);
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
