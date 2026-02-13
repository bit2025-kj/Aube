import '../database/database_helper.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> initialize() async {
    debugPrint(' NotificationService initialisé');
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    return await _dbHelper.getNotifications();
  }

  Future<void> markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _dbHelper.markAllAsRead();
  }

  Future<void> deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
  }

  Future<int> getUnreadCount() async {
    return await _dbHelper.countUnreadNotifications();
  }

  Future<Map<String, dynamic>> getSettings() async {
    return await _dbHelper.getNotificationSettings();
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _dbHelper.updateNotificationSettings(settings);
  }

  Future<void> createTestNotification() async {
    final notification = {
      'title': 'Notification de test',
      'description': 'Ceci est une notification de démonstration',
      'type': 'test',
      'sub_type': 'test_simple',
      'operator_type': 'all',
      'created_at': DateTime.now().toIso8601String(),
      'is_read': 0,
      'is_archived': 0,
      'priority': 'low',
      'metadata': '{}',
    };

    await _dbHelper.insertNotification(notification);
  }

  // Méthode pour créer une notification transactionnelle
  Future<void> createTransactionNotification({
    required String operatorType,
    required double amount,
    required bool isSuccess,
    String? clientName,
    String? clientPhone,
    double? commission,
  }) async {
    final operatorName = operatorType == 'orange' ? 'Orange Money' : 'Moov Money';
    final title = isSuccess
        ? 'Transaction réussie - $operatorName'
        : 'Transaction échouée - $operatorName';

    final description = isSuccess
        ? '${amount.toStringAsFixed(0)} FCFA ${operatorType == 'orange' ? 'déposés' : 'retirés'} pour ${clientName ?? clientPhone ?? 'un client'}'
        : 'Échec de transaction de ${amount.toStringAsFixed(0)} FCFA';

    final notification = {
      'title': title,
      'description': description,
      'type': 'transaction',
      'sub_type': isSuccess ? 'deposit_success' : 'deposit_failed',
      'operator_type': operatorType,
      'amount': amount,
      'commission': commission,
      'client_name': clientName,
      'client_phone': clientPhone,
      'is_read': 0,
      'is_archived': 0,
      'priority': isSuccess ? 'medium' : 'high',
      'created_at': DateTime.now().toIso8601String(),
      'metadata': '{}',
    };

    await _dbHelper.insertNotification(notification);

    // Si commission, créer aussi une notification de commission
    if (isSuccess && commission != null && commission > 0) {
      await createCommissionNotification(
        amount: commission,
        clientName: clientName,
      );
    }
  }

  Future<void> createCommissionNotification({
    required double amount,
    String? clientName,
  }) async {
    final notification = {
      'title': 'Commission reçue',
      'description': '+${amount.toStringAsFixed(0)} FCFA de commission${clientName != null ? ' pour $clientName' : ''}',
      'type': 'commission',
      'sub_type': 'commission_received',
      'operator_type': 'all',
      'amount': amount,
      'commission': amount,
      'client_name': clientName,
      'is_read': 0,
      'is_archived': 0,
      'priority': 'low',
      'created_at': DateTime.now().toIso8601String(),
      'metadata': '{}',
    };

    await _dbHelper.insertNotification(notification);
  }
}


