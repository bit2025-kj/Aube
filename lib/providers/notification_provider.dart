import 'package:flutter/material.dart';
import 'package:aube/pages/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // ✅ CORRECTION: Utilisez List<Map<String, dynamic>> au lieu de List<NotificationModel>
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic> _settings = {};
  int _unreadCount = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  Map<String, dynamic> get settings => _settings;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Initialiser
  Future<void> initialize() async {
    await _notificationService.initialize();
    await loadNotifications();
    await loadSettings();
    await loadUnreadCount();
  }

  // ✅ CORRECTION: Enlevez les paramètres type et isRead qui n'existent pas
  Future<void> loadNotifications({bool refresh = false}) async {
    if (!refresh && _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // ✅ CORRECTION: Appel simple sans paramètres
      _notifications = await _notificationService.getNotifications();
    } catch (error) {
      debugPrint('Erreur lors du chargement des notifications: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les paramètres
  Future<void> loadSettings() async {
    _settings = await _notificationService.getSettings();
    notifyListeners();
  }

  // Charger le compte des non lues
  Future<void> loadUnreadCount() async {
    _unreadCount = await _notificationService.getUnreadCount();
    notifyListeners();
  }

  // Marquer comme lu
  Future<void> markAsRead(int id) async {
    // ✅ CORRECTION: Mettre à jour localement
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['is_read'] = 1;
      _notifications[index]['read_at'] = DateTime.now().toIso8601String();
      notifyListeners();
    }

    await _notificationService.markAsRead(id);
    await loadUnreadCount();
  }

  // Marquer toutes comme lues
  Future<void> markAllAsRead() async {
    // ✅ CORRECTION: Mettre à jour localement
    for (var notification in _notifications) {
      if (notification['is_read'] == 0) {
        notification['is_read'] = 1;
        notification['read_at'] = DateTime.now().toIso8601String();
      }
    }
    notifyListeners();

    await _notificationService.markAllAsRead();
    await loadUnreadCount();
  }

  // ✅ CORRECTION: Supprimez archiveNotification si elle n'existe pas dans NotificationService
  // Archive (optionnel - supprimez si non utilisé)
  Future<void> archiveNotification(int id) async {
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();

    // Si votre service n'a pas cette méthode, supprimez cette ligne
    // await _notificationService.archiveNotification(id);
    await loadUnreadCount();
  }

  // Supprimer
  Future<void> deleteNotification(int id) async {
    _notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();

    await _notificationService.deleteNotification(id);
    await loadUnreadCount();
  }

  // Mettre à jour les paramètres
  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    _settings = newSettings;
    notifyListeners();

    await _notificationService.updateSettings(newSettings);
  }

  // ✅ CORRECTION: Utilisez la méthode simple qui existe
  Future<void> createTestNotification() async {
    await _notificationService.createTestNotification();

    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }

  // ✅ CORRECTION: Supprimez cleanup et close si elles n'existent pas
  // Pas besoin de ces méthodes si elles n'existent pas dans NotificationService
}



