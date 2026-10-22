import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../services/repository_manager.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RepositoryManager>(
      builder: (context, repoMgr, child) {
        final isOnline = repoMgr.isOnline;

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Colors.amber.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Offline Mode - Changes are saved locally and will sync automatically when back online.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => repoMgr.setOnlineStatus(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Go Online', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ConnectivityIndicatorBadge extends StatelessWidget {
  final bool compact;
  const ConnectivityIndicatorBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<RepositoryManager>(
      builder: (context, repoMgr, child) {
        final isOnline = repoMgr.isOnline;

        return Tooltip(
          message: isOnline
              ? 'Online: Realtime Supabase sync active'
              : 'Offline: Changes will sync automatically',
          child: InkWell(
            onTap: () {
              // Allows manual testing of offline capability
              repoMgr.setOnlineStatus(!isOnline);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isOnline
                        ? 'Simulating Offline Mode (Changes persist locally)'
                        : 'Simulating Online Mode (Syncing data)',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 4),
              margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 6),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.online.withAlpha(30) : Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOnline ? AppColors.online : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? AppColors.online : Colors.orange,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOnline ? AppColors.online : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
