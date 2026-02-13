import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as developer;
import 'package:aube/models/subscription.dart';
import 'package:aube/services/ad_service.dart';
import 'package:aube/models/advertisement.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AdService? _adService; // Optional dependency to avoid breaking existing constructor immediately if not passed
  
  NotificationService([this._adService]);

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: null,
    );
  }

  Future<void> showNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'subscription_channel',
      'Subscription Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(
      id,
      title,
      body,
      details,
    );
  }

  Future<void> showAdNotification(Advertisement ad) async {
    // Utilise le hashcode du titre comme ID car pas d'ID unique dans le modèle
    final notifId = 1000 + ad.title.hashCode;
    
    await showNotification(
      notifId,
      "Offre Spéciale: ${ad.title}",
      ad.message, 
    );
  }

  Future<void> scheduleExpirationNotifications(Subscription sub) async {
    final expiresAt = DateTime.parse(sub.expiresAt);
    
    // Notification for 3 days before
    final threeDaysBefore = expiresAt.subtract(const Duration(days: 3));
    if (threeDaysBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: 101, // Unique ID
        title: 'Abonnement expire bientôt',
        body: 'Votre abonnement expire dans 3 jours.',
        scheduledDate: threeDaysBefore,
      );
    }

    // Notification for 1 day before
    final oneDayBefore = expiresAt.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: 102, // Unique ID
        title: 'Abonnement expire demain',
        body: 'Attention, votre abonnement expire demain !',
        scheduledDate: oneDayBefore,
      );
      
      // Also schedule Ad notifications for the eve of expiration if AdService is available
      if (_adService != null) {
         _scheduleAdNotifications(oneDayBefore);
      }
    }
  }

  Future<void> _scheduleAdNotifications(DateTime scheduledDate) async {
    try {
      final ads = await _adService!.getAds();
      if (ads.isNotEmpty) {
        // Schedule a notification for each active ad, slightly offset or just one summary
        // Requirement: "la partie notification va afficher les ads aussi"
        // Let's pick the first active ad for now to avoid spamming
        final activeAds = ads.where((ad) => ad.isActive).toList();
        
        if (activeAds.isNotEmpty) {
           final ad = activeAds.first;
           // Schedule it 1 hour after the warning or same time? 
           // Let's put it 5 minutes after the warning
           final adTime = scheduledDate.add(const Duration(minutes: 5));
           
           await _scheduleNotification(
             id: 200,
             title: 'Offre Spéciale: ${ad.title}',
             body: ad.message,
             scheduledDate: adTime,
           );
        }
      }
    } catch (e) {
      developer.log('Error scheduling ad notifications', name: 'NotificationService', error: e);
    }
  }

  Future<void> _scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  developer.log('Scheduling notification "$title" for $scheduledDate', name: 'NotificationService');

  try {
    // Essaye de programmer en exact
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_channel',
          'Subscription Notifications',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    developer.log('Notification scheduled in exact mode', name: 'NotificationService');
  } on PlatformException catch (e) {
    // Si exact n’est pas permis → fallback inexact
    developer.log('Exact alarm not permitted, using inexact mode', name: 'NotificationService', error: e);
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_channel',
          'Subscription Notifications',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    developer.log('Notification scheduled in inexact mode', name: 'NotificationService');
  }
}

  
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}



