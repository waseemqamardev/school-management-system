import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../features/notifications/notification_center_screen.dart';
import 'connectivity_banner.dart';
import 'firebase_status_dialog.dart';

class ShellDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class ResponsiveShell extends StatelessWidget {
  final String title;
  final String roleBadge;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<ShellDestination> destinations;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? extraActions;

  const ResponsiveShell({
    super.key,
    required this.title,
    required this.roleBadge,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final unreadCount = notifProvider.unreadCount;

    final allActions = <Widget>[
      const ConnectivityIndicatorBadge(),
      IconButton(
        tooltip: 'Supabase / Database Status',
        icon: const Icon(Icons.dns_rounded, size: 21),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const BackendStatusDialog(),
          );
        },
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Notification Center',
            icon: const Icon(Icons.notifications_rounded, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
              );
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.absent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.absent.withAlpha(90),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 900.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
        ],
      ),
      ...?extraActions,
      PopupMenuButton<String>(
        tooltip: 'Account Menu',
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.5),
          ),
          child: const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.person, size: 18, color: AppColors.primary),
          ),
        ),
        onSelected: (val) {
          if (val == 'logout') {
            auth.logout();
          } else if (val == 'setup') {
            showDialog(
              context: context,
              builder: (_) => const FirebaseStatusDialog(),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.currentUser?.name ?? 'Signed In User',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15),
                ),
                Text(
                  auth.currentUser?.email ?? '',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    auth.currentUser?.role.toUpperCase() ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'setup',
            child: Row(
              children: [
                Icon(Icons.cloud_sync_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Database / Backend Info'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 18, color: AppColors.absent),
                SizedBox(width: 10),
                Text('Sign Out', style: TextStyle(color: AppColors.absent, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];

    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Dar-e-Arqam',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                '•  $title',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 17),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha(60), width: 1),
                ),
                child: Text(
                  roleBadge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: allActions,
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onIndexChanged,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'IQRA',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: AppColors.goldAccentDark,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon, color: AppColors.primary),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.015, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(currentIndex),
                  child: body,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Mobile / Tablet Layout
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
                if (width > 340) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      roleBadge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'Dar-e-Arqam Digital School',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          const ConnectivityIndicatorBadge(compact: true),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Notification Center',
                icon: const Icon(Icons.notifications_rounded, size: 22),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.absent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          ...?extraActions,
          PopupMenuButton<String>(
            tooltip: 'Account Menu',
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.person, size: 16, color: AppColors.primary),
              ),
            ),
            onSelected: (val) {
              if (val == 'logout') {
                auth.logout();
              } else if (val == 'setup') {
                showDialog(
                  context: context,
                  builder: (_) => const BackendStatusDialog(),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.currentUser?.name ?? 'Signed In User',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                    ),
                    Text(
                      auth.currentUser?.email ?? '',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'setup',
                child: Row(
                  children: [
                    Icon(Icons.cloud_sync_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text('Database / Backend Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: AppColors.absent),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(color: AppColors.absent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: body,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onIndexChanged,
          destinations: destinations,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ShellDestination> destinations;

  const BottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: destinations.asMap().entries.map((entry) {
            final idx = entry.key;
            final dest = entry.value;
            final isSelected = idx == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(idx),
                borderRadius: BorderRadius.circular(12),
                splashColor: AppColors.rippleBlue,
                highlightColor: AppColors.rippleYellow.withAlpha(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer.withAlpha(160) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? dest.selectedIcon : dest.icon,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        size: 21,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          dest.label,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentYellow,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
