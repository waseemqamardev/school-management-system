import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../models/diary_entry_model.dart';
import '../../models/subject_model.dart';
import '../../providers/parent_provider.dart';
import '../../widgets/scroll_3d_effects.dart';

class ParentDiaryScreen extends StatefulWidget {
  final bool isStandalone;
  const ParentDiaryScreen({super.key, this.isStandalone = false});

  @override
  State<ParentDiaryScreen> createState() => _ParentDiaryScreenState();
}

class _ParentDiaryScreenState extends State<ParentDiaryScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic> _diaryData = {};
  String _selectedSubjectFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  void _loadDiary() async {
    setState(() => _isLoading = true);
    final parentProvider = context.read<ParentProvider>();
    final data = await parentProvider.loadDiaryForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _diaryData = data;
        _isLoading = false;
      });
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadDiary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final selectedChild = parentProvider.selectedChild;
    final subjects = (parentProvider.classSubjects);
    final entries = (_diaryData['entries'] as Map<String, DiaryEntry>?) ?? {};
    final isPublished = _diaryData['diary']?.published ?? false;

    return Scaffold(
      appBar: widget.isStandalone
          ? AppBar(title: Text('Today\'s Diary', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
          : null,
      body: selectedChild == null
          ? Center(
              child: Text(
                'No student linked to this parent account.',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                // Top Date Selector & Navigation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.chevron_left_rounded, size: 24),
                        onPressed: () {
                          setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                          _loadDiary();
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                                      maxLines: 1,
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.chevron_right_rounded, size: 24),
                        onPressed: () {
                          setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                          _loadDiary();
                        },
                      ),
                      if (DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now())) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'TODAY',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Published Notification Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isPublished ? AppColors.presentLight : Colors.amber.shade50,
                    border: Border(
                      bottom: BorderSide(
                        color: isPublished ? AppColors.present.withAlpha(50) : Colors.amber.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPublished ? Icons.verified_rounded : Icons.info_outline_rounded,
                        size: 17,
                        color: isPublished ? AppColors.present : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPublished
                            ? 'Official Diary Published by School'
                            : 'Diary draft in progress by teachers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPublished ? AppColors.present : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subject Filter Chips Row
                if (subjects.isNotEmpty)
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: [
                        _buildFilterChip('All'),
                        ...subjects.map((s) => _buildFilterChip(s.name)),
                      ],
                    ),
                  ),

                // Diary Subject Cards List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : () {
                          final filteredSubjects = _selectedSubjectFilter == 'All'
                              ? subjects
                              : subjects.where((s) => s.name.toLowerCase() == _selectedSubjectFilter.toLowerCase()).toList();

                          if (filteredSubjects.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    SchoolConstants.emptyDiaryAsset,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (_, _, _) => const Icon(Icons.menu_book, size: 64, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No Diary for $_selectedSubjectFilter',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Teachers haven\'t posted homework for this subject yet.',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async => _loadDiary(),
                            color: AppColors.primary,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredSubjects.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final subject = filteredSubjects[index];
                                final entry = entries[subject.subjectId];
                                return Scroll3DItem(
                                  child: _SubjectDiaryCard(
                                    subject: subject,
                                    entry: entry,
                                    animationDelayMs: index * 50,
                                  ),
                                );
                              },
                            ),
                          );
                        }(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedSubjectFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _selectedSubjectFilter = label);
        },
        selectedColor: AppColors.primaryContainer,
        checkmarkColor: AppColors.primary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
    );
  }
}

IconData _getSubjectIcon(String name) {
  final l = name.toLowerCase();
  if (l.contains('math')) return Icons.calculate_rounded;
  if (l.contains('sci')) return Icons.biotech_rounded;
  if (l.contains('eng')) return Icons.translate_rounded;
  if (l.contains('urdu')) return Icons.menu_book_rounded;
  if (l.contains('isl')) return Icons.mosque_rounded;
  if (l.contains('comp')) return Icons.laptop_chromebook_rounded;
  return Icons.auto_stories_rounded;
}

Color _getSubjectColor(String name) {
  final l = name.toLowerCase();
  if (l.contains('math')) return const Color(0xFF2563EB);
  if (l.contains('sci')) return const Color(0xFF059669);
  if (l.contains('eng')) return const Color(0xFF7C3AED);
  if (l.contains('urdu')) return const Color(0xFFD97706);
  if (l.contains('isl')) return const Color(0xFF0F5132);
  if (l.contains('comp')) return const Color(0xFF0891B2);
  return AppColors.primary;
}

class _SubjectDiaryCard extends StatelessWidget {
  final Subject subject;
  final DiaryEntry? entry;
  final int animationDelayMs;

  const _SubjectDiaryCard({
    required this.subject,
    this.entry,
    this.animationDelayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntry = entry != null && entry!.isCompleted;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasEntry ? AppColors.primary.withAlpha(50) : AppColors.border,
            width: hasEntry ? 1.5 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: hasEntry ? _getSubjectColor(subject.name).withAlpha(25) : AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getSubjectIcon(subject.name),
                          color: hasEntry ? _getSubjectColor(subject.name) : AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subject.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasEntry ? AppColors.primaryContainer : AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasEntry ? AppColors.primary.withAlpha(90) : AppColors.border,
                    ),
                  ),
                  child: Text(
                    hasEntry ? 'Given' : 'No Diary',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: hasEntry ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),

            // Content or "Aaj diary nahi di gayi."
            if (!hasEntry)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aaj diary nahi di gayi.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              if (entry!.classwork.isNotEmpty)
                _FieldRow(
                  label: 'Classwork',
                  value: entry!.classwork,
                  icon: Icons.edit_note_rounded,
                  color: AppColors.primary,
                ),
              if (entry!.homework.isNotEmpty)
                _FieldRow(
                  label: 'Homework',
                  value: entry!.homework,
                  icon: Icons.home_work_outlined,
                  color: Colors.blue.shade700,
                ),
              if (entry!.testInfo.isNotEmpty)
                _FieldRow(
                  label: 'Upcoming Test',
                  value: entry!.testInfo,
                  icon: Icons.assignment_outlined,
                  color: Colors.deepOrange,
                ),
              if (entry!.instructions.isNotEmpty)
                _FieldRow(
                  label: 'Instructions',
                  value: entry!.instructions,
                  icon: Icons.info_outline_rounded,
                  color: AppColors.goldAccentDark,
                ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: animationDelayMs.ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FieldRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 13.5, height: 1.4),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
