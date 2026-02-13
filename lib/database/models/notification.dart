class NotificationModel {
  int? id;
  String title;
  String description;
  String type; // 'transaction', 'commission', 'security', 'summary'
  String subType; // 'deposit_success', 'deposit_failed', 'commission_received', etc.
  String operatorType; // 'orange', 'moov', 'all'
  double? amount;
  double? commission;
  String? clientName;
  String? clientPhone;
  bool isRead;
  bool isArchived;
  String priority; // 'low', 'medium', 'high', 'urgent'
  DateTime createdAt;
  DateTime? readAt;
  Map<String, dynamic> metadata;

  NotificationModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.subType = 'deposit_success',
    this.operatorType = 'all',
    this.amount,
    this.commission,
    this.clientName,
    this.clientPhone,
    this.isRead = false,
    this.isArchived = false,
    this.priority = 'medium',
    DateTime? createdAt,
    this.readAt,
    this.metadata = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'type': type,
      'sub_type': subType,
      'operator_type': operatorType,
      'amount': amount,
      'commission': commission,
      'client_name': clientName,
      'client_phone': clientPhone,
      'is_read': isRead ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'metadata': _mapToJson(metadata),
    };
  }

  // Convertir depuis Map (depuis SQLite)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      subType: map['sub_type'],
      operatorType: map['operator_type'],
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      commission: map['commission'] != null ? (map['commission'] as num).toDouble() : null,
      clientName: map['client_name'],
      clientPhone: map['client_phone'],
      isRead: map['is_read'] == 1,
      isArchived: map['is_archived'] == 1,
      priority: map['priority'],
      createdAt: DateTime.parse(map['created_at']),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
      metadata: _jsonToMap(map['metadata']),
    );
  }

  // Méthode pour marquer comme lu
  void markAsRead() {
    if (!isRead) {
      isRead = true;
      readAt = DateTime.now();
    }
  }

  // Méthode pour archiver
  void archive() {
    isArchived = true;
  }

  // Factory pour une notification transactionnelle
  factory NotificationModel.transaction({
    required String title,
    required String description,
    required String operatorType,
    required double amount,
    String? clientName,
    String? clientPhone,
    bool isSuccess = true,
    double? commission,
  }) {
    return NotificationModel(
      title: title,
      description: description,
      type: 'transaction',
      subType: isSuccess ? 'deposit_success' : 'deposit_failed',
      operatorType: operatorType,
      amount: amount,
      commission: commission,
      clientName: clientName,
      clientPhone: clientPhone,
      priority: isSuccess ? 'medium' : 'high',
    );
  }

  // Factory pour une notification de commission
  factory NotificationModel.commission({
    required double amount,
    String? clientName,
  }) {
    return NotificationModel(
      title: 'Commission reçue',
      description: '+${amount.toStringAsFixed(0)} FCFA de commission${clientName != null ? ' pour $clientName' : ''}',
      type: 'commission',
      subType: 'commission_received',
      amount: amount,
      priority: 'low',
    );
  }

  // Factory pour une notification de sécurité
  factory NotificationModel.security({
    required String eventType,
    String? location,
    String? device,
  }) {
    String title = 'Alerte de sécurité';
    String description = '';

    switch (eventType) {
      case 'login_alert':
        description = 'Connexion depuis ${location ?? 'un nouvel appareil'}${device != null ? ' ($device)' : ''}';
        break;
      case 'password_changed':
        description = 'Votre mot de passe a été modifié avec succès';
        break;
      case 'suspicious_activity':
        description = 'Activité suspecte détectée sur votre compte';
        break;
      default:
        description = 'Événement de sécurité détecté';
    }

    return NotificationModel(
      title: title,
      description: description,
      type: 'security',
      subType: eventType,
      priority: 'high',
      metadata: {
        'location': location,
        'device': device,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Helper methods pour JSON
  static String _mapToJson(Map<String, dynamic> map) {
    return map.isEmpty ? '{}' : map.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
  }

  static Map<String, dynamic> _jsonToMap(String json) {
    if (json.isEmpty || json == '{}') return {};
    final map = <String, dynamic>{};
    final entries = json.replaceAll('{', '').replaceAll('}', '').split(',');
    for (var entry in entries) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        map[parts[0].replaceAll('"', '')] = parts[1].replaceAll('"', '');
      }
    }
    return map;
  }
}


