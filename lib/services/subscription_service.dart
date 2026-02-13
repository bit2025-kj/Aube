import 'dart:convert';
import 'dart:developer' as developer;
import 'package:aube/models/subscription.dart';
import 'package:aube/services/api_service.dart';
import 'package:aube/services/device_service.dart';

class SubscriptionService {
  final ApiService _apiService;
  final DeviceService _deviceService;

  SubscriptionService(this._apiService, this._deviceService);

  /// Récupère l'abonnement actuel pour le device de l'utilisateur
  Future<Subscription?> getMySubscription() async {
    try {
      // Charge le token automatiquement si besoin
      await _apiService.loadTokenIfNeeded();
      
      // Récupère le device_id
      final deviceId = await _deviceService.getDeviceId();
      developer.log('Getting subscription for device: $deviceId', name: 'SubscriptionService');
      
      final response = await _apiService.get(
        '/v1/subscriptions/my-subscription?device_id=$deviceId'
      );

      developer.log('Response status: ${response.statusCode}', name: 'SubscriptionService');
      developer.log('Response body: ${response.body}', name: 'SubscriptionService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Subscription.fromJson(data);
      } else if (response.statusCode == 404) {
        // Aucun abonnement trouvé
        developer.log('No subscription found', name: 'SubscriptionService');
        return null;
      } else if (response.statusCode == 401) {
        developer.log('Unauthorized: token missing or invalid', name: 'SubscriptionService');
        throw Exception('Unauthorized: token missing or invalid');
      } else {
        throw Exception('Failed to get subscription: ${response.body}');
      }
    } catch (e) {
      developer.log(
        'Error getting subscription',
        name: 'SubscriptionService',
        error: e,
      );
      rethrow;
    }
  }

  /// Crée une nouvelle demande d'abonnement
  Future<Subscription> requestSubscription({
    String? planId,
    String? phoneNumber,
    int? months,
    String? planName,
    double? amount,
    int? durationDays,
  }) async {
    try {
      await _apiService.loadTokenIfNeeded();

      // Récupère les informations du device
      final deviceId = await _deviceService.getDeviceId();
      final deviceInfo = await _deviceService.getDeviceInfo();

      final Map<String, dynamic> payload;
      
      if (planId != null) {
        payload = {
          'plan_id': planId,
          'device_id': deviceId,
          'device_name': deviceInfo['device_name'] ?? 'Unknown',
          'os_type': deviceInfo['os_type'] ?? 'Unknown',
        };
      } else {
        if (phoneNumber == null ||
            months == null ||
            planName == null ||
            amount == null ||
            durationDays == null) {
          throw ArgumentError('Either planId or all subscription details must be provided');
        }
        payload = {
          'device_id': deviceId,
          'phone_number': phoneNumber,
          'months': months,
          'plan_name': planName,
          'amount': amount,
          'duration_days': durationDays,
          'device_name': deviceInfo['device_name'] ?? 'Unknown',
          'os_type': deviceInfo['os_type'] ?? 'Unknown',
        };
      }

      developer.log('Requesting subscription with payload: $payload', name: 'SubscriptionService');

      final response = await _apiService.post('/v1/subscriptions/request', payload);

      developer.log('Response status: ${response.statusCode}', name: 'SubscriptionService');
      developer.log('Response body: ${response.body}', name: 'SubscriptionService');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Subscription.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: token missing or invalid');
      } else if (response.statusCode == 409) {
        throw Exception('Active subscription already exists for this device');
      } else {
        throw Exception('Failed to request subscription: ${response.body}');
      }
    } catch (e) {
      developer.log(
        'Error requesting subscription',
        name: 'SubscriptionService',
        error: e,
      );
      rethrow;
    }
  }

  /// Vérifie si un abonnement est actif
  bool isSubscriptionActive(Subscription? sub) {
    if (sub == null) return false;
    if (sub.status != 'validated' && sub.status != 'active') return false;
    try {
      return DateTime.parse(sub.expiresAt).isAfter(DateTime.now());
    } catch (e) {
      developer.log('Error parsing expiration date', name: 'SubscriptionService', error: e);
      return false;
    }
  }

  /// Retourne le nombre de jours avant expiration
  int daysUntilExpiration(Subscription sub) {
    try {
      final expiresAt = DateTime.parse(sub.expiresAt);
      final days = expiresAt.difference(DateTime.now()).inDays;
      return days > 0 ? days : 0;
    } catch (e) {
      developer.log('Error calculating days until expiration', name: 'SubscriptionService', error: e);
      return 0;
    }
  }
}


