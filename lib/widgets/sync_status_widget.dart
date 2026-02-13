// lib/widgets/sync_status_widget.dart

import 'package:aube/services/sync_transactions_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isSyncing = false;
  bool _isDownloading = false;
  DateTime? _lastSyncDate;
  DateTime? _lastDownloadDate;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    final syncService = Provider.of<SyncService>(context, listen: false);
    final lastSync = await syncService.getLastSyncDate();
    final lastDownload = await syncService.getLastDownloadDate();
    
    if (mounted) {
      setState(() {
        _lastSyncDate = lastSync;
        _lastDownloadDate = lastDownload;
      });
    }
  }

  Future<void> _fullSync() async {
    setState(() => _isSyncing = true);

    final syncService = Provider.of<SyncService>(context, listen: false);
    final success = await syncService.forceSync();

    if (mounted) {
      setState(() => _isSyncing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? '✅ Synchronisation bidirectionnelle réussie' 
              : '❌ Échec de la synchronisation'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        _loadDates();
      }
    }
  }

  Future<void> _downloadOnly() async {
    setState(() => _isDownloading = true);

    final syncService = Provider.of<SyncService>(context, listen: false);
    final success = await syncService.forceDownload();

    if (mounted) {
      setState(() => _isDownloading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? '✅ Transactions téléchargées depuis le serveur' 
              : '❌ Échec du téléchargement'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        _loadDates();
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays} jours';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sync, color: Color(0xFF6200EE)),
                SizedBox(width: 12),
                Text(
                  'Synchronisation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dernière sync bidirectionnelle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dernière sync complète:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  _formatDate(_lastSyncDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Dernier téléchargement
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dernier téléchargement:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  _formatDate(_lastDownloadDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Bouton sync complète
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing || _isDownloading ? null : _fullSync,
                icon: _isSyncing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
                label: Text(
                  _isSyncing 
                    ? 'Synchronisation...' 
                    : 'Synchronisation complète'
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bouton téléchargement uniquement
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSyncing || _isDownloading ? null : _downloadOnly,
                icon: _isDownloading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_download),
                label: Text(
                  _isDownloading 
                    ? 'Téléchargement...' 
                    : 'Récupérer du serveur uniquement'
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              '💡 Synchronisation bidirectionnelle:\n'
              '• Upload: Envoie les transactions locales vers le serveur\n'
              '• Download: Récupère vos transactions depuis le serveur\n'
              '• Automatique toutes les 5 minutes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}