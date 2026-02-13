import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aube/services/api_service.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  DeviceService(this._apiService);

  /// Récupère un identifiant unique et PERSISTANT pour cet appareil
  Future<String> getDeviceId() async {
    // 1. Essayer de récupérer l'identifiant matériel natif (survit à la réinstallation)
    String? hardwareId;
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        // androidId est unique à l'appareil et à la signature de l'app (survit réinstallation)
        hardwareId = androidInfo.id; 
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        // identifierForVendor est unique pour le vendor (survit tant qu'une app du vendor est installée)
        hardwareId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      developer.log('Failed to get hardware ID: $e', name: 'DeviceService');
    }

    // 2. Si on a un ID matériel, on le transforme en UUID v5 pour que le backend l'accepte
    // Le v5 est déterministe : Même input (Hardware ID) = Même UUID.
    if (hardwareId != null && hardwareId.isNotEmpty) {
      // Utilisation d'un namespace constant (DNS) pour la génération
      final persistentUuid = _uuid.v5(Uuid.NAMESPACE_DNS, hardwareId);
      
      await _storage.write(key: 'device_uuid', value: persistentUuid);
      developer.log('Generated Persistent UUID v5 from HardwareID ($hardwareId): $persistentUuid', name: 'DeviceService');
      return persistentUuid;
    }

    // 3. Fallback : UUID aléatoire stocké (Perdu si désinstallation)
    String? storedUuid = await _storage.read(key: 'device_uuid');
    
    if (storedUuid == null || storedUuid.isEmpty) {
      storedUuid = _uuid.v4();
      await _storage.write(key: 'device_uuid', value: storedUuid);
      developer.log('Generated new RANDOM Device UUID (Fallback): $storedUuid', name: 'DeviceService');
    } else {
      developer.log('Using existing stored Device UUID: $storedUuid', name: 'DeviceService');
    }
    
    return storedUuid;
  }

  /// Récupère les informations de l'appareil
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceName = 'Unknown Device';
    String osType = 'Unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
        osType = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceName = '${iosInfo.name} (${iosInfo.model})';
        osType = 'iOS ${iosInfo.systemVersion}';
      }
    } catch (e) {
      developer.log('Error getting device info', name: 'DeviceService', error: e);
    }

    return {
      'device_name': deviceName,
      'os_type': osType,
    };
  }

  /// Enregistre l'appareil actuel auprès du backend
  Future<void> registerCurrentDevice() async {
    try {
      await _apiService.loadTokenIfNeeded();

      final deviceId = await getDeviceId();
      final deviceInfo = await getDeviceInfo();

      final payload = {
        'device_id': deviceId,
        'device_name': deviceInfo['device_name'],
        'os_type': deviceInfo['os_type'],
        'is_primary': false,
      };

      developer.log('Registering device: $payload', name: 'DeviceService');

      final response = await _apiService.post('/v1/user/register-device', payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log(
          'Device registered successfully: ${deviceInfo['device_name']} ($deviceId)',
          name: 'DeviceService',
        );
      } else if (response.statusCode == 422) {
        developer.log(
          'Validation error: ${response.body}',
          name: 'DeviceService',
        );
        throw Exception('Device registration validation failed: ${response.body}');
      } else {
        developer.log(
          'Failed to register device: ${response.statusCode} - ${response.body}',
          name: 'DeviceService',
        );
        throw Exception('Failed to register device: ${response.body}');
      }
    } catch (e) {
      developer.log('Error registering device', name: 'DeviceService', error: e);
      rethrow;
    }
  }

  /// Liste tous les appareils de l'utilisateur
  Future<List<Map<String, dynamic>>> listDevices() async {
    try {
      await _apiService.loadTokenIfNeeded();

      final response = await _apiService.get('/v1/user/devices');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to list devices: ${response.body}');
      }
    } catch (e) {
      developer.log('Error listing devices', name: 'DeviceService', error: e);
      return [];
    }
  }

  /// Supprime un appareil
  Future<bool> removeDevice(String deviceId) async {
    try {
      await _apiService.loadTokenIfNeeded();

      final response = await _apiService.post('/v1/user/remove-device', {
        'device_id': deviceId,
      });

      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error removing device', name: 'DeviceService', error: e);
      return false;
    }
  }
}


