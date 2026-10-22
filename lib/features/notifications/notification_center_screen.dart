import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      context.read<NotificationProvider>().loadNotifications(auth.currentUser!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Center', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                if (auth.currentUser != null) {
                  notifProvider.markAllAsRead(auth.currentUser!.userId);
                }
              },
              icon: const Icon(Icons.done_all_rounded, color: AppColors.primary, size: 18),
              label: Text('Mark All Read', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(120),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.primary),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No notifications yet',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will receive live alerts for attendance, diaries, and exam results.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _NotificationTile(
                      notification: notif,
                      animationDelayMs: index * 40,
                      onTap: () {
                        notifProvider.markAsRead(notif.notificationId);
                        _showNotificationDetail(context, notif);
                      },
                    );
                  },
                ),
    );
  }

  void _showNotificationDetail(BuildContext context, AppNotification notif) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            _buildTypeIcon(notif.type),
            const SizedBox(width: 12),
            Expanded(
              child: Text(notif.title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif.body, style: GoogleFonts.plusJakartaSans(fontSize: 14.5, height: 1.45, color: AppColors.textPrimary)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Received: ${DateFormat('EEE, d MMM yyyy • hh:mm a').format(notif.createdAt)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    switch (type) {
      case 'attendance':
      case 'attendance_correction':
        return const Icon(Icons.co_present_rounded, color: AppColors.absent);
      case 'diary':
        return const Icon(Icons.menu_book_rounded, color: AppColors.primary);
      case 'marks':
        return const Icon(Icons.grade_rounded, color: AppColors.goldAccentDark);
      default:
        return const Icon(Icons.info_rounded, color: AppColors.leave);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final int animationDelayMs;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.animationDelayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;
    final timeStr = DateFormat('MMM d, hh:mm a').format(notification.createdAt);

    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case 'attendance':
        typeColor = AppColors.absent;
        typeIcon = Icons.event_busy_rounded;
        break;
      case 'attendance_correction':
        typeColor = AppColors.present;
        typeIcon = Icons.published_with_changes_rounded;
        break;
      case 'diary':
        typeColor = AppColors.primary;
        typeIcon = Icons.menu_book_rounded;
        break;
      case 'marks':
        typeColor = AppColors.goldAccentDark;
        typeIcon = Icons.grade_rounded;
        break;
      default:
        typeColor = AppColors.leave;
        typeIcon = Icons.notifications_rounded;
    }

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? typeColor.withAlpha(90) : AppColors.border,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread ? AppColors.cardShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: typeColor.withAlpha(25),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.absent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: GoogleFonts.outfit(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  timeStr,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notification.body,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
          ),
        ),
      ),
    )
        .animate(delay: animationDelayMs.ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.05, end: 0);
  }
}
