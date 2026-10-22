import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/school_constants.dart';
import '../models/student_model.dart';
import 'link_child_dialog.dart';

/// 1. Vertical 3D Perspective Scroll Item
/// Smoothly rotates and scales cards in 3D perspective along the X-axis
/// as they scroll into and out of the viewport.
class Scroll3DItem extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle; // Radians, default ~7.5 degrees
  final double depth; // Perspective focal depth

  const Scroll3DItem({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.13,
    this.depth = 0.0015,
  });

  @override
  State<Scroll3DItem> createState() => _Scroll3DItemState();
}

class _Scroll3DItemState extends State<Scroll3DItem> {
  ScrollableState? _scrollable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollable = Scrollable.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_scrollable == null) {
      return widget.child;
    }

    final position = _scrollable!.position;

    return AnimatedBuilder(
      animation: position,
      builder: (context, child) {
        if (!context.mounted) return widget.child;
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize) {
          return widget.child;
        }

        final scrollableBox = _scrollable!.context.findRenderObject() as RenderBox?;
        if (scrollableBox == null || !scrollableBox.hasSize) {
          return widget.child;
        }

        final itemOffset = renderBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
        final viewportHeight = scrollableBox.size.height;
        if (viewportHeight <= 0) return widget.child;

        final itemCenterY = itemOffset.dy + (renderBox.size.height / 2);
        final normalizedCenter = ((itemCenterY - (viewportHeight / 2)) / (viewportHeight / 2)).clamp(-1.2, 1.2);

        // Rotation angle based on distance from center
        final angleX = -normalizedCenter * widget.maxTiltAngle;
        final scale = (1.0 - (normalizedCenter.abs() * 0.04)).clamp(0.92, 1.0);

        final transform = Matrix4.identity()
          ..setEntry(3, 2, widget.depth) // 3D Perspective
          ..rotateX(angleX)
          ..scaleByDouble(scale, scale, 1.0, 1.0);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// 2. Horizontal 3D Coverflow Carousel for Student Switching
/// Enables parents to swipe through their linked children with a
/// 3D perspective fold, scale and depth shading.
class Student3DCoverflowCarousel extends StatefulWidget {
  final List<Student> children;
  final Student? selectedChild;
  final ValueChanged<Student> onChildSelected;

  const Student3DCoverflowCarousel({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  @override
  State<Student3DCoverflowCarousel> createState() => _Student3DCoverflowCarouselState();
}

class _Student3DCoverflowCarouselState extends State<Student3DCoverflowCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.selectedChild != null
        ? widget.children.indexWhere((c) => c.studentId == widget.selectedChild!.studentId)
        : 0;
    _currentPage = initialIndex >= 0 ? initialIndex : 0;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.88,
    );
  }

  @override
  void didUpdateWidget(covariant Student3DCoverflowCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedChild != null && widget.selectedChild != oldWidget.selectedChild) {
      final index = widget.children.indexWhere((c) => c.studentId == widget.selectedChild!.studentId);
      if (index >= 0 && index != _currentPage && _pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCards = widget.children.length + 1; // +1 for "Link Child" card

    return SizedBox(
      height: 195,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: totalCards,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          if (page < widget.children.length) {
            widget.onChildSelected(widget.children[page]);
          }
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double relativePosition = 0.0;
              if (_pageController.position.haveDimensions) {
                relativePosition = index - _pageController.page!;
              } else {
                relativePosition = (index - _currentPage).toDouble();
              }

              // 3D Perspective Transformations
              final clampedDist = relativePosition.clamp(-1.0, 1.0);
              final rotateY = clampedDist * -0.28; // ~16 deg 3D tilt
              final scale = (1.0 - (relativePosition.abs() * 0.08)).clamp(0.85, 1.0);
              final opacity = (1.0 - (relativePosition.abs() * 0.35)).clamp(0.45, 1.0);

              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.0018) // 3D depth
                ..rotateY(rotateY)
                ..scaleByDouble(scale, scale, 1.0, 1.0);

              return Transform(
                alignment: relativePosition > 0 ? Alignment.centerLeft : Alignment.centerRight,
                transform: transform,
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              );
            },
            child: index < widget.children.length
                ? _buildStudent3DCard(widget.children[index], index == _currentPage)
                : _buildAddChild3DCard(),
          );
        },
      ),
    );
  }

  Widget _buildStudent3DCard(Student student, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]
              : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? AppColors.accentYellow : Colors.white24,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected ? AppColors.yellowGlow : [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onChildSelected(student),
          borderRadius: BorderRadius.circular(22),
          splashColor: AppColors.rippleYellow,
          highlightColor: AppColors.rippleYellow.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.accentYellow : Colors.white38,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accentYellow.withAlpha(90),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(SchoolConstants.getStudentAvatar(student.name)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.accentYellow : Colors.white24,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        student.linkCode,
                                        style: GoogleFonts.outfit(
                                          color: isSelected ? AppColors.primaryDark : Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Roll #${student.rollNumber} • Class 8-A',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentYellow : Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.accentYellow : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                            size: 13,
                            color: isSelected ? AppColors.primaryDark : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSelected ? 'ACTIVE' : 'SELECT',
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? AppColors.primaryDark : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: isSelected ? AppColors.accentYellow : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Dar-e-Arqam Student',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Swipe for 3D View ➜',
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? AppColors.accentYellow : Colors.white54,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddChild3DCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary, width: 2, style: BorderStyle.solid),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const LinkChildDialog(),
            );
          },
          borderRadius: BorderRadius.circular(22),
          splashColor: AppColors.rippleBlue,
          highlightColor: AppColors.rippleYellow.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  'Connect Another Child',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to enter Unique Link ID or Class',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
