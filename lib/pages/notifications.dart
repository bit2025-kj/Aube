import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:aube/pages/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Services et helpers
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  // Paramètres de notification (chargés depuis la base)
  bool _transactionNotifications = true;
  bool _securityNotifications = true;
  bool _commissionNotifications = true;
  bool _dailySummary = false;
  String _dailySummaryTime = '20:00';
  bool _silentNotifications = false;
  bool _vibration = true;

  // Historique des notifications (chargé depuis la base)
  List<Map<String, dynamic>> _notifications = []; // ✅ Changé à Map
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialiser les données
  Future<void> _initializeData() async {
    await _notificationService.initialize();
    await _loadSettings();
    await _loadNotifications();
    await _loadUnreadCount();
  }

  // Charger les paramètres depuis la base
  Future<void> _loadSettings() async {
    final settings = await _dbHelper.getNotificationSettings();
    setState(() {
      _transactionNotifications = settings['transactionNotifications'];
      _securityNotifications = settings['securityNotifications'];
      _commissionNotifications = settings['commissionNotifications'];
      _dailySummary = settings['dailySummary'];
      _dailySummaryTime = settings['dailySummaryTime'];
      _silentNotifications = settings['silentNotifications'];
      _vibration = settings['vibration'];
    });
  }

  // Charger les notifications depuis la base
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _dbHelper
          .getNotifications(); // ✅ Supprimé les paramètres
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint(
        'Erreur lors du chargement des notifications: $error',
      ); // ✅ debugPrint
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Charger le nombre de notifications non lues
  Future<void> _loadUnreadCount() async {
    final count = await _dbHelper.countUnreadNotifications();
    setState(() {
      _unreadCount = count;
    });
  }

  // Sauvegarder les paramètres dans la base
  Future<void> _saveSettings() async {
    final settings = {
      'transactionNotifications': _transactionNotifications,
      'securityNotifications': _securityNotifications,
      'commissionNotifications': _commissionNotifications,
      'dailySummary': _dailySummary,
      'dailySummaryTime': _dailySummaryTime,
      'silentNotifications': _silentNotifications,
      'vibration': _vibration,
    };

    await _dbHelper.updateNotificationSettings(settings);
  }

  // Marquer toutes les notifications comme lues
  Future<void> _markAllAsRead() async {
    await _dbHelper.markAllAsRead();
    await _loadNotifications();
    await _loadUnreadCount();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les notifications marquées comme lues'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Marquer une notification comme lue
  Future<void> _markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
    await _loadNotifications();
    await _loadUnreadCount();
  }

  // ✅ Supprimé _archiveNotification car elle n'existe pas dans DatabaseHelper
  // Utilisez _deleteNotification à la place

  // Supprimer une notification
  Future<void> _deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
    await _loadNotifications();
    await _loadUnreadCount();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification supprimée'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Créer une notification de test
  Future<void> _createTestNotification() async {
    await _notificationService
        .createTestNotification(); // ✅ Changé à createTestNotification

    await _loadNotifications();
    await _loadUnreadCount();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification de test créée'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Formater le temps relatif
  String _formatTime(String dateString) {
    // ✅ Changé le paramètre
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Il y a ${difference.inSeconds} secondes';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} minutes';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours} heures';
      } else if (difference.inDays == 1) {
        return 'Hier, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return 'Date inconnue';
    }
  }

  // Obtenir l'icône selon le type
  IconData _getIconForType(String type, String subType) {
    switch (type) {
      case 'transaction':
        return subType.contains('success')
            ? Icons.check_circle_outline
            : Icons.error_outline;
      case 'commission':
        return Icons.monetization_on_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'summary':
        return Icons.summarize_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  // Obtenir la couleur selon le type
  Color _getColorForType(String type, String subType) {
    switch (type) {
      case 'transaction':
        return subType.contains('success') ? Colors.green : Colors.red;
      case 'commission':
        return Colors.orange;
      case 'security':
        return Colors.blue;
      case 'summary':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Badge(
              label: Text(_unreadCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.checklist_outlined),
                onPressed: _markAllAsRead,
                tooltip: 'Tout marquer comme lu',
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'test') {
                _createTestNotification();
              } else if (value == 'clear') {
                // Option pour vider les notifications
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.add_alert_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Créer une notification de test'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Nettoyer les anciennes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section paramètres
                  _buildSettingsSection(),

                  // Section historique
                  _buildHistorySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paramètres de notification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A4F7A),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Choisissez les types de notifications que vous souhaitez recevoir',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Transaction notifications
            SwitchListTile(
              title: const Text('Notifications transactionnelles'),
              subtitle: const Text('Alertes pour chaque dépôt/retrait'),
              value: _transactionNotifications,
              onChanged: (value) {
                setState(() {
                  _transactionNotifications = value;
                  _saveSettings();
                });
              },
              secondary: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.green,
              ),
            ),

            // Security notifications
            SwitchListTile(
              title: const Text('Notifications de sécurité'),
              subtitle: const Text(
                'Alertes de connexion et sécurité du compte',
              ),
              value: _securityNotifications,
              onChanged: (value) {
                setState(() {
                  _securityNotifications = value;
                  _saveSettings();
                });
              },
              secondary: const Icon(
                Icons.security_outlined,
                color: Color(0xFF3A4F7A),
              ),
            ),

            // Commission notifications
            SwitchListTile(
              title: const Text('Notifications de commission'),
              subtitle: const Text('Alertes pour chaque commission reçue'),
              value: _commissionNotifications,
              onChanged: (value) {
                setState(() {
                  _commissionNotifications = value;
                  _saveSettings();
                });
              },
              secondary: const Icon(
                Icons.monetization_on_outlined,
                color: Colors.orange,
              ),
            ),

            // Silent notifications
            SwitchListTile(
              title: const Text('Mode silencieux'),
              subtitle: const Text('Pas de son pour les notifications'),
              value: _silentNotifications,
              onChanged: (value) {
                setState(() {
                  _silentNotifications = value;
                  _saveSettings();
                });
              },
              secondary: const Icon(
                Icons.volume_off_outlined,
                color: Colors.grey,
              ),
            ),

            // Vibration
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrer pour les notifications'),
              value: _vibration,
              onChanged: (value) {
                setState(() {
                  _vibration = value;
                  _saveSettings();
                });
              },
              secondary: const Icon(
                Icons.vibration_outlined,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_notifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune notification',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vous serez notifié ici des nouvelles activités',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _createTestNotification,
              icon: const Icon(Icons.add_alert_outlined),
              label: const Text('Créer une notification de test'),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historique des notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A4F7A),
                    ),
                  ),
                  Text(
                    '$_unreadCount non lue${_unreadCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _unreadCount > 0 ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // ✅ Supprimé .toList() dans le spread
            ..._notifications.map((notification) {
              final id = notification['id'] as int;
              final isRead = notification['is_read'] == 1;
              final type = notification['type'] as String? ?? 'test';
              final subType = notification['sub_type'] as String? ?? '';
              final title = notification['title'] as String? ?? 'Notification';
              final description = notification['description'] as String? ?? '';
              final createdAt = notification['created_at'] as String? ?? '';
              final amount = notification['amount'] as num?;

              return Dismissible(
                key: ValueKey(id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer la notification'),
                        content: const Text(
                          'Voulez-vous vraiment supprimer cette notification ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return false;
                },
                onDismissed: (direction) {
                  _deleteNotification(id);
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getColorForType(type, subType).withOpacity(
                            0.1,
                          ), // ✅ Gardé avecOpacity pour simplicité
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getIconForType(type, subType),
                          color: _getColorForType(type, subType),
                          size: 22,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: isRead ? Colors.black87 : Colors.black,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3A4F7A),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _formatTime(createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (amount != null && amount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    '${amount.toStringAsFixed(0)} FCFA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getColorForType(type, subType),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        if (!isRead) {
                          _markAsRead(id);
                        }
                      },
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.mark_email_read_outlined,
                                ),
                                title: const Text('Marquer comme lu'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _markAsRead(id);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _deleteNotification(id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (notification != _notifications.last)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}



