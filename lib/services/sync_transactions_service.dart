// lib/services/sync_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:aube/services/transactions_service.dart';
import 'package:aube/database/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' as drift;

class SyncService {
  final TransactionService _transactionService;
  final AppDatabase _localDb;
  final _storage = const FlutterSecureStorage();
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  SyncService(this._transactionService, this._localDb);

  /// Démarre la synchronisation automatique bidirectionnelle
  void startAutoSync() {
    // 1. Synchroniser uniquement l'upload au démarrage (Download manuel)
    _uploadLocalTransactions();

    // 2. Écouter les changements de connectivité
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print('📡 Connexion détectée: $result');
        // Au retour de la connexion, on tente un upload pour ne pas perdre de données
        _uploadLocalTransactions();
      }
    });

    // 3. Synchroniser périodiquement (toutes les 5 minutes) - UPLOAD SEULEMENT
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      print('⏰ Auto-sync timer (Upload Only)');
      _uploadLocalTransactions();
    });
  }

  /// Arrête la synchronisation automatique
  void stopAutoSync() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  /// Synchronisation complète bidirectionnelle
  Future<void> _fullSync() async {
    final connectivity = await Connectivity().checkConnectivity();
    
    if (connectivity == ConnectivityResult.none) {
      print('📵 Pas de connexion internet');
      return;
    }

    // Vérifier si l'utilisateur est connecté
    final token = await _storage.read(key: 'token');
    if (token == null) {
      print('🔒 Utilisateur non connecté, sync annulée');
      return;
    }

    // Vérifier la dernière synchronisation
    final lastSyncStr = await _storage.read(key: 'last_sync');
    if (lastSyncStr != null) {
      final lastSync = DateTime.parse(lastSyncStr);
      final diff = DateTime.now().difference(lastSync);
      
      if (diff.inMinutes < 3) {
        print('⏱️ Sync récente (il y a ${diff.inMinutes} min), skip');
        return;
      }
    }

    try {
      print('🔄 Démarrage de la synchronisation bidirectionnelle...');
      
      // 1. UPLOAD: Envoyer les transactions locales vers le serveur
      await _uploadLocalTransactions();
      
      // 2. DOWNLOAD: Récupérer les transactions du serveur
      await _downloadServerTransactions();
      
      await _storage.write(key: 'last_sync', value: DateTime.now().toIso8601String());
      print('✅ Synchronisation bidirectionnelle réussie');
    } catch (e) {
      print('❌ Erreur synchronisation: $e');
    }
  }

  /// ⬆️ Upload: Envoie les transactions locales vers le serveur
  Future<bool> _uploadLocalTransactions() async {
    try {
      final localTransactions = await _localDb.getAllCoins();
      
      if (localTransactions.isEmpty) {
        print('📤 Aucune transaction locale à uploader');
        return true;
      }

      final transactionsData = localTransactions.map((trans) {
        return {
          'nom': trans.nom,
          'prenom': trans.prenom,
          'type_de_piece': trans.typeDePiece,
          'numero_de_piece': trans.numeroDePiece,
          'date_de_peremption': trans.dateDePeremption.toIso8601String(),
          'type_de_transaction': trans.typeDeTransaction,
          'montant': trans.montant,
          'operateur': trans.operateur,
          'numero_de_telephone': trans.numeroDeTelephone,
          'date_de_transaction': trans.dateDeTransaction.toIso8601String(),
        };
      }).toList();

      final success = await _transactionService.syncLocalTransactions(transactionsData);
      
      if (success) {
        print('✅ ${localTransactions.length} transactions uploadées');
      }
      
      return success;
    } catch (e) {
      print('❌ Erreur upload: $e');
      return false;
    }
  }

  /// ⬇️ Download: Récupère les transactions du serveur et les enregistre localement
  Future<bool> _downloadServerTransactions() async {
    try {
      // Récupérer la dernière date de download
      final lastDownloadStr = await _storage.read(key: 'last_download');
      DateTime? lastDownload;
      if (lastDownloadStr != null) {
        lastDownload = DateTime.parse(lastDownloadStr);
      }

      // Récupérer toutes les transactions du serveur
      // Récupérer toutes les transactions du serveur avec pagination
      List<dynamic> serverTransactions = [];
      int skip = 0;
      const int batchSize = 100;

      while (true) {
        final batch = await _transactionService.getServerTransactions(
          limit: batchSize,
          skip: skip,
        );
        
        if (batch.isEmpty) break;
        serverTransactions.addAll(batch);
        
        if (batch.length < batchSize) break;
        skip += batchSize;
      }

      if (serverTransactions.isEmpty) {
        print('📥 Aucune transaction serveur à télécharger');
        return true;
      }

      int newCount = 0;
      int updatedCount = 0;

      for (final serverTrans in serverTransactions) {
        try {
          // Vérifier si la transaction existe déjà localement
          final existingLocal = await _findLocalTransaction(serverTrans);

          if (existingLocal == null) {
            // Nouvelle transaction: insérer
            await _insertServerTransactionLocally(serverTrans);
            newCount++;
          } else {
            // Transaction existante: vérifier si elle a été modifiée
            final serverDate = DateTime.parse(serverTrans['date_de_transaction']);
            if (serverDate.isAfter(existingLocal.dateDeTransaction)) {
              // La version serveur est plus récente: mettre à jour
              await _updateLocalTransaction(existingLocal.id, serverTrans);
              updatedCount++;
            }
          }
        } catch (e) {
          print('⚠️ Erreur traitement transaction: $e');
          continue;
        }
      }

      await _storage.write(key: 'last_download', value: DateTime.now().toIso8601String());
      print('✅ Download terminé: $newCount nouvelles, $updatedCount mises à jour');
      
      return true;
    } catch (e) {
      print('❌ Erreur download: $e');
      return false;
    }
  }

  /// Trouve une transaction locale correspondante
  Future<CoinsTableData?> _findLocalTransaction(Map<String, dynamic> serverTrans) async {
    final allLocal = await _localDb.getAllCoins();
    
    // Chercher par numéro de pièce et date de transaction
    for (final local in allLocal) {
      if (local.numeroDePiece == serverTrans['numero_de_piece'] &&
          // Comparaison de la date sans les millisecondes pour éviter les problèmes de précision
          local.dateDeTransaction.toIso8601String().split('.')[0] == 
          serverTrans['date_de_transaction'].split('.')[0]) {
        return local;
      }
    }
    
    return null;
  }

  /// Insère une transaction du serveur dans la base locale
  Future<void> _insertServerTransactionLocally(Map<String, dynamic> serverTrans) async {
    await _localDb.insertCoin(
      CoinsTableCompanion(
        nom: drift.Value(serverTrans['nom']),
        prenom: drift.Value(serverTrans['prenom']),
        typeDePiece: drift.Value(serverTrans['type_de_piece']),
        numeroDePiece: drift.Value(serverTrans['numero_de_piece']),
        dateDePeremption: drift.Value(DateTime.parse(serverTrans['date_de_peremption'])),
        typeDeTransaction: drift.Value(serverTrans['type_de_transaction']),
        montant: drift.Value(serverTrans['montant'].toDouble()),
        operateur: drift.Value(serverTrans['operateur']),
        numeroDeTelephone: drift.Value(serverTrans['numero_de_telephone']),
        dateDeTransaction: drift.Value(DateTime.parse(serverTrans['date_de_transaction'])),
      ),
    );
  }

  /// Met à jour une transaction locale avec les données du serveur
  Future<void> _updateLocalTransaction(int localId, Map<String, dynamic> serverTrans) async {
    final updated = CoinsTableData(
      id: localId,
      nom: serverTrans['nom'],
      prenom: serverTrans['prenom'],
      typeDePiece: serverTrans['type_de_piece'],
      numeroDePiece: serverTrans['numero_de_piece'],
      dateDePeremption: DateTime.parse(serverTrans['date_de_peremption']),
      typeDeTransaction: serverTrans['type_de_transaction'],
      montant: serverTrans['montant'].toDouble(),
      operateur: serverTrans['operateur'],
      numeroDeTelephone: serverTrans['numero_de_telephone'],
      dateDeTransaction: DateTime.parse(serverTrans['date_de_transaction']),
    );
    
    await _localDb.updateCoin(updated);
  }

  /// Force une synchronisation bidirectionnelle manuelle
  Future<bool> forceSync() async {
    print('🔄 Synchronisation forcée...');
    
    try {
      await _uploadLocalTransactions();
      await _downloadServerTransactions();
      await _storage.write(key: 'last_sync', value: DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      print('❌ Erreur sync forcée: $e');
      return false;
    }
  }

  /// Force uniquement le téléchargement depuis le serveur
  Future<bool> forceDownload() async {
    print('📥 Téléchargement forcé depuis le serveur...');
    
    try {
      final success = await _downloadServerTransactions();
      if (success) {
        await _storage.write(key: 'last_download', value: DateTime.now().toIso8601String());
      }
      return success;
    } catch (e) {
      print('❌ Erreur download forcé: $e');
      return false;
    }
  }

  /// Récupère la date de la dernière synchronisation
  Future<DateTime?> getLastSyncDate() async {
    final lastSyncStr = await _storage.read(key: 'last_sync');
    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }
    return null;
  }

  /// Récupère la date du dernier téléchargement
  Future<DateTime?> getLastDownloadDate() async {
    final lastDownloadStr = await _storage.read(key: 'last_download');
    if (lastDownloadStr != null) {
      return DateTime.parse(lastDownloadStr);
    }
    return null;
  }
}