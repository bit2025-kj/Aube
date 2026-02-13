import 'dart:convert';
import 'dart:developer' as developer;
import 'package:aube/models/advertisement.dart';
import 'package:aube/services/api_service.dart';

class AdService {
  final ApiService _apiService;

  AdService(this._apiService);

  Future<List<Advertisement>> getAds() async {
    try {
      final response = await _apiService.get('/v1/ads');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> adsList = data['ads'];
        return adsList.map((json) => Advertisement.fromJson(json)).toList();
      } else {
        developer.log('Failed to load ads: ${response.statusCode}', name: 'AdService');
        return [];
      }
    } catch (e) {
      developer.log('Error loading ads', name: 'AdService', error: e);
      return [];
    }
  }
}



