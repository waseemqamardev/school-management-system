import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import '../../models/subject_model.dart';
import '../../models/parent_model.dart';
import '../../providers/admin_provider.dart';

class AdminManagementScreen extends StatefulWidget {
  final bool isStandalone;
  const AdminManagementScreen({super.key, this.isStandalone = false});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dialog to Add/Edit Student
  void _showStudentDialog([Student? student]) {
    final admin = context.read<AdminProvider>();
    final isEditing = student != null;
    final nameCtrl = TextEditingController(text: student?.name ?? '');
    final rollCtrl = TextEditingController(text: student?.rollNumber ?? '');
    final codeCtrl = TextEditingController(text: student?.linkCode ?? 'ARQ-8A-');
    String selectedClassId = student?.classId ?? (admin.classes.isNotEmpty ? admin.classes.first.classId : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? 'Edit Student' : 'Add New Student', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Student Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rollCtrl,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Unique Link ID (for Parent App)',
                    hintText: 'e.g. ARQ-8A-01',
                    prefixIcon: Icon(Icons.vpn_key_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedClassId.isNotEmpty ? selectedClassId : null,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: admin.classes.map((c) {
                    return DropdownMenuItem(value: c.classId, child: Text(c.displayName));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedClassId = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || rollCtrl.text.trim().isEmpty) return;

                final updated = Student(
                  studentId: student?.studentId ?? 'student_${_uuid.v4().substring(0, 8)}',
                  name: nameCtrl.text.trim(),
                  rollNumber: rollCtrl.text.trim(),
                  classId: selectedClassId,
                  parentIds: student?.parentIds ?? [],
                  active: student?.active ?? true,
                  linkCode: codeCtrl.text.trim().isNotEmpty ? codeCtrl.text.trim().toUpperCase() : null,
                );

                await admin.saveStudent(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Student'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to Add/Edit Class
  void _showClassDialog([SchoolClass? schoolClass]) {
    final admin = context.read<AdminProvider>();
    final isEditing = schoolClass != null;
    final nameCtrl = TextEditingController(text: schoolClass?.name ?? 'Class 9');
    final sectionCtrl = TextEditingController(text: schoolClass?.section ?? 'A');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? 'Edit Class' : 'Add New Class', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Class Name (e.g. Class 9)')),
            const SizedBox(height: 12),
            TextField(controller: sectionCtrl, decoration: const InputDecoration(labelText: 'Section (e.g. A or B)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || sectionCtrl.text.trim().isEmpty) return;

              final updated = SchoolClass(
                classId: schoolClass?.classId ?? 'class_${_uuid.v4().substring(0, 8)}',
                schoolId: 'school_darearqam_01',
                name: nameCtrl.text.trim(),
                section: sectionCtrl.text.trim(),
                classTeacherId: schoolClass?.classTeacherId ?? '',
              );

              await admin.saveClass(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Save Changes' : 'Create Class'),
          ),
        ],
      ),
    );
  }

  // Dialog to Add/Edit Subject
  void _showSubjectDialog([Subject? subject]) {
    final admin = context.read<AdminProvider>();
    final isEditing = subject != null;
    final nameCtrl = TextEditingController(text: subject?.name ?? '');
    String selectedClassId = subject?.classId ?? (admin.classes.isNotEmpty ? admin.classes.first.classId : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEditing ? 'Edit Subject' : 'Add New Subject', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Subject Name (e.g. History)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedClassId.isNotEmpty ? selectedClassId : null,
                decoration: const InputDecoration(labelText: 'Assigned Class'),
                items: admin.classes.map((c) {
                  return DropdownMenuItem(value: c.classId, child: Text(c.displayName));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedClassId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;

                final updated = Subject(
                  subjectId: subject?.subjectId ?? 'sub_${_uuid.v4().substring(0, 8)}',
                  name: nameCtrl.text.trim(),
                  classId: selectedClassId,
                  teacherId: subject?.teacherId ?? 'teacher_01',
                );

                await admin.saveSubject(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Save Changes' : 'Create Subject'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to Add Teacher
  void _showAddTeacherDialog() {
    final admin = context.read<AdminProvider>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Teacher Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Teacher Name (e.g. Sir Rashid)')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Phone')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;

              await admin.createTeacherUserAndProfile(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                assignedClassIds: admin.classes.isNotEmpty ? [admin.classes.first.classId] : [],
                assignedSubjectIds: [],
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create Teacher'),
          ),
        ],
      ),
    );
  }

  // Dialog to Add Parent
  void _showAddParentDialog() {
    final admin = context.read<AdminProvider>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Parent Account', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Parent/Guardian Full Name')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Phone')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;

              await admin.createParentUserAndProfile(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                studentIds: admin.students.isNotEmpty ? [admin.students.first.studentId] : [],
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create Parent'),
          ),
        ],
      ),
    );
  }

  // Dialog to Link / Unlink Students from a Parent
  void _showManageParentStudentsDialog(ParentProfile parent, dynamic user) {
    final admin = context.read<AdminProvider>();
    final selectedStudentIds = List<String>.from(parent.studentIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Link Students', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Parent: ${user.name}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textSecondary)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: admin.students.isEmpty
                ? const Text('No students found to link.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: admin.students.length,
                    itemBuilder: (context, i) {
                      final st = admin.students[i];
                      final isLinked = selectedStudentIds.contains(st.studentId);
                      return CheckboxListTile(
                        dense: true,
                        value: isLinked,
                        title: Text(st.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        subtitle: Text('Roll #${st.rollNumber} • Class 8-A', style: GoogleFonts.plusJakartaSans(fontSize: 11.5)),
                        onChanged: (bool? val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedStudentIds.add(st.studentId);
                            } else {
                              selectedStudentIds.remove(st.studentId);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await admin.updateParentStudentLinks(
                  parentUserId: parent.userId,
                  updatedStudentIds: selectedStudentIds,
                );
              },
              child: const Text('Save Links'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: widget.isStandalone ? AppBar(title: Text('School Management CRUD', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))) : null,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13.5),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(text: 'Students (${admin.students.length})'),
                Tab(text: 'Teachers (${admin.teachers.length})'),
                Tab(text: 'Classes (${admin.classes.length})'),
                Tab(text: 'Subjects (${admin.subjects.length})'),
                Tab(text: 'Parents (${admin.parents.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Students Tab
                _buildListTab(
                  items: admin.students,
                  emptyText: 'No students enrolled.',
                  onAdd: () => _showStudentDialog(),
                  addButtonLabel: 'Add Student',
                  itemBuilder: (st) {
                    final cls = admin.classes.firstWhere(
                      (c) => c.classId == st.classId,
                      orElse: () => SchoolClass(classId: '', schoolId: '', name: 'Class', section: '', classTeacherId: ''),
                    );
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: AssetImage(SchoolConstants.getStudentAvatar(st.name)),
                        radius: 20,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              st.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              st.linkCode,
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text('Roll #${st.rollNumber} • ${cls.displayName} • Active: ${st.active}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _showStudentDialog(st),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.absent),
                            onPressed: () => admin.deactivateStudent(st.studentId),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 2. Teachers Tab
                _buildListTab(
                  items: admin.teachers,
                  emptyText: 'No teachers registered.',
                  onAdd: _showAddTeacherDialog,
                  addButtonLabel: 'Add Teacher',
                  itemBuilder: (t) {
                    final user = admin.users.firstWhere(
                      (u) => u.userId == t.userId,
                      orElse: () => admin.users.first,
                    );
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      title: Text(user.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      subtitle: Text('${user.email} • ${user.phone}\nClasses: ${t.assignedClassIds.join(', ')}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                      isThreeLine: true,
                    );
                  },
                ),

                // 3. Classes Tab
                _buildListTab(
                  items: admin.classes,
                  emptyText: 'No classes created.',
                  onAdd: () => _showClassDialog(),
                  addButtonLabel: 'Add Class',
                  itemBuilder: (c) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.goldAccentLight,
                        child: const Icon(Icons.meeting_room_rounded, color: AppColors.goldAccentDark),
                      ),
                      title: Text(c.displayName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      subtitle: Text('Section: ${c.section} • Class ID: ${c.classId}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _showClassDialog(c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.absent),
                            onPressed: () => admin.deleteClass(c.classId),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 4. Subjects Tab
                _buildListTab(
                  items: admin.subjects,
                  emptyText: 'No subjects added.',
                  onAdd: () => _showSubjectDialog(),
                  addButtonLabel: 'Add Subject',
                  itemBuilder: (subj) {
                    final cls = admin.classes.firstWhere(
                      (c) => c.classId == subj.classId,
                      orElse: () => SchoolClass(classId: '', schoolId: '', name: 'Class', section: '', classTeacherId: ''),
                    );
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: const Icon(Icons.book_rounded, color: AppColors.primary),
                      ),
                      title: Text(subj.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      subtitle: Text('Taught in: ${cls.displayName}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _showSubjectDialog(subj),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.absent),
                            onPressed: () => admin.deleteSubject(subj.subjectId),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 5. Parents Tab
                _buildListTab(
                  items: admin.parents,
                  emptyText: 'No parents registered.',
                  onAdd: _showAddParentDialog,
                  addButtonLabel: 'Add Parent',
                  itemBuilder: (p) {
                    final user = admin.users.firstWhere(
                      (u) => u.userId == p.userId,
                      orElse: () => admin.users.first,
                    );
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withAlpha(20),
                        child: const Icon(Icons.family_restroom_rounded, color: Colors.blue),
                      ),
                      title: Text(user.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      subtitle: Text('${user.email} • ${user.phone}\nLinked Students: ${p.studentIds.length} children', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.link_rounded, color: AppColors.primary),
                        tooltip: 'Link / Manage Students',
                        onPressed: () => _showManageParentStudentsDialog(p, user),
                      ),
                      onTap: () => _showManageParentStudentsDialog(p, user),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab<T>({
    required List<T> items,
    required String emptyText,
    required VoidCallback onAdd,
    required String addButtonLabel,
    required Widget Function(T item) itemBuilder,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Records: ${items.length}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(addButtonLabel, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(emptyText, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)))
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return RepaintBoundary(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: itemBuilder(item),
                      ),
                    )
                        .animate(delay: (index * 25).ms)
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: 0.04, end: 0);
                  },
                ),
        ),
      ],
    );
  }
}
