import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../providers/parent_provider.dart';
import '../../widgets/scroll_3d_effects.dart';

class ParentResultsScreen extends StatelessWidget {
  final bool isStandalone;
  const ParentResultsScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final child = parentProvider.selectedChild;
    final marks = parentProvider.childMarks;
    final avgPercentage = parentProvider.averageMarksPercentage;

    return Scaffold(
      appBar: isStandalone ? AppBar(title: Text('Marks & Report Cards', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))) : null,
      body: child == null
          ? Center(child: Text('No student linked.', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Performance Summary Card
                  RepaintBoundary(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.accentYellow.withAlpha(80), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentYellow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ACADEMIC REPORT',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.primaryDark,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${avgPercentage.toStringAsFixed(1)}%',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cumulative Average • ${marks.length} Tests Recorded',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accentYellow.withAlpha(120), width: 1.5),
                            ),
                            child: Image.asset(
                              SchoolConstants.trophyAsset,
                              width: 48,
                              height: 48,
                              errorBuilder: (_, _, _) => const Icon(Icons.stars_rounded, color: AppColors.accentYellow, size: 36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assessment Reports',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Read Only',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (marks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Center(
                        child: Text(
                          'No test records published yet for this student.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: marks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final mark = marks[index];
                        final pct = mark.percentage;
                        final color = pct >= 80
                            ? AppColors.present
                            : (pct >= 50 ? Colors.orange.shade800 : AppColors.absent);

                        String subjectName = 'Subject';
                        for (final s in parentProvider.classSubjects) {
                          if (s.subjectId == mark.subjectId) {
                            subjectName = s.name;
                            break;
                          }
                        }

                        return Scroll3DItem(
                          child: RepaintBoundary(
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
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: color.withAlpha(20),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(Icons.school_rounded, color: color, size: 20),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          subjectName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                                                        ),
                                                        Text(
                                                          '${mark.examType} • ${DateFormat('dd MMM yyyy').format(mark.createdAt)}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${mark.obtainedMarks.toStringAsFixed(mark.obtainedMarks.truncateToDouble() == mark.obtainedMarks ? 0 : 1)} / ${mark.totalMarks.toInt()}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w800,
                                                    color: color,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: color.withAlpha(20),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${pct.toStringAsFixed(1)}%',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w800,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                if (mark.feedback.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundElevated,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.format_quote_rounded, size: 18, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            mark.feedback,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: (index * 40).ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.05, end: 0);
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
