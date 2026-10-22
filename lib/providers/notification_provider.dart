import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/repository_manager.dart';

class NotificationProvider extends ChangeNotifier {
  final RepositoryManager _repoManager;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._repoManager);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repoManager.repository.getNotificationsForUser(userId);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
      await _repoManager.repository.markNotificationAsRead(notificationId);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    notifyListeners();
    await _repoManager.repository.markAllNotificationsAsRead(userId);
  }
}
