// lib/services/transaction_service.dart

import 'dart:convert';
import 'package:aube/services/api_service.dart';

class TransactionService {
  final ApiService _apiService;

  TransactionService(this._apiService);

  /// Synchronise les transactions locales vers le serveur
  Future<bool> syncLocalTransactions(List<Map<String, dynamic>> transactionsData) async {
    try {
      if (transactionsData.isEmpty) {
        return true;
      }

      final response = await _apiService.post('/v1/transactions/sync', {
        'transactions': transactionsData,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ ${data['count']} transactions synchronisées');
        return true;
      } else {
        print('❌ Erreur sync: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur syncLocalTransactions: $e');
      return false;
    }
  }

  /// Récupère les transactions depuis le serveur
  Future<List<Map<String, dynamic>>> getServerTransactions({
    int limit = 100,
    int skip = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/transactions/my-transactions?limit=$limit&skip=$skip',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur récupération transactions: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getServerTransactions: $e');
      rethrow;
    }
  }

  /// Récupère les statistiques de l'utilisateur
  Future<Map<String, dynamic>> getMyStats() async {
    try {
      final response = await _apiService.get('/v1/transactions/my-stats');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur récupération stats: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur getMyStats: $e');
      rethrow;
    }
  }

  /// Crée une transaction directement sur le serveur
  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    try {
      final response = await _apiService.post(
        '/v1/transactions/',
        transactionData,
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur création transaction: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur createTransaction: $e');
      rethrow;
    }
  }
}