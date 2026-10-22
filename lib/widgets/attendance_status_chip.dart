import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';

class AttendanceStatusChip extends StatelessWidget {
  final String status;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const AttendanceStatusChip({
    super.key,
    required this.status,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    Color baseColor;
    Color lightColor;
    String label;
    IconData icon;

    switch (normalized) {
      case 'present':
      case 'p':
        baseColor = AppColors.present;
        lightColor = AppColors.presentLight;
        label = compact ? 'P' : 'Present';
        icon = Icons.check_circle_rounded;
        break;
      case 'absent':
      case 'a':
        baseColor = AppColors.absent;
        lightColor = AppColors.absentLight;
        label = compact ? 'A' : 'Absent';
        icon = Icons.cancel_rounded;
        break;
      case 'late':
      case 'l':
        baseColor = AppColors.late;
        lightColor = AppColors.lateLight;
        label = compact ? 'L' : 'Late';
        icon = Icons.schedule_rounded;
        break;
      case 'leave':
      case 'lv':
        baseColor = AppColors.leave;
        lightColor = AppColors.leaveLight;
        label = compact ? 'LV' : 'Leave';
        icon = Icons.medical_services_rounded;
        break;
      default:
        baseColor = AppColors.pending;
        lightColor = AppColors.pendingLight;
        label = compact ? '?' : 'Pending';
        icon = Icons.hourglass_top_rounded;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: baseColor.withAlpha(90), width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: baseColor,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? baseColor : lightColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? baseColor : baseColor.withAlpha(80),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: baseColor.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? Colors.white : baseColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : baseColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 180.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
