import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(context),

            // Section 1: Introduction
            _buildSection(
              context: context,
              title: '1. Introduction',
              icon: Icons.info_outline,
              content:
                  'Cette Politique de Confidentialité décrit comment notre application de gestion des transactions '
                  'collecte, utilise et protège vos données personnelles.\n\n'
                  'La première utilisation de l’application nécessite une connexion Internet afin d’activer et sécuriser '
                  'le compte utilisateur. Après cette étape, l’application fonctionne principalement hors ligne.',
            ),

            _buildSection(
              context: context,
              title: '2. Données collectées',
              icon: Icons.storage_outlined,
              content:
                  'Nous collectons uniquement les données nécessaires au bon fonctionnement de l’application :\n\n'
                  '• Informations de l’agent : nom, numéro de téléphone.\n'
                  '• Données de transaction : type d’opération, montant, opérateur, date et heure.\n'
                  '• Données techniques : version de l’application et identifiant interne.\n\n'
                  'Aucune donnée inutile ou excessive n’est collectée.',
            ),

            _buildSection(
              context: context,
              title: '3. Utilisation des données',
              icon: Icons.settings_outlined,
              content:
                  'Les données collectées servent exclusivement à :\n\n'
                  '• Enregistrer et gérer les transactions.\n'
                  '• Générer des rapports et statistiques.\n'
                  '• Assurer la sécurité et l’intégrité des données.\n\n'
                  'Nous ne vendons ni ne louons vos données personnelles.',
            ),

            _buildSection(
              context: context,
              title: '4. Fonctionnement hors ligne',
              icon: Icons.wifi_off_outlined,
              content:
                  'Après l’activation initiale nécessitant Internet, l’application fonctionne hors ligne.\n\n'
                  'Les données sont stockées localement sur l’appareil de l’utilisateur. '
                  'Aucune synchronisation automatique en ligne n’est effectuée sans action volontaire.',
            ),

            _buildSection(
              context: context,
              title: '5. Sécurité des données',
              icon: Icons.security_outlined,
              content:
                  'Nous mettons en œuvre des mesures de sécurité professionnelles :\n\n'
                  '• Stockage local sécurisé.\n'
                  '• Accès protégé par authentification.\n'
                  '• Chiffrement des données sensibles.\n'
                  '• Accès limité aux développeurs.\n\n'
                  'L’utilisateur est responsable de la sécurité physique de son appareil.',
            ),

            _buildSection(
              context: context,
              title: '6. Partage des données',
              icon: Icons.share_outlined,
              content:
                  'Vos données ne sont jamais partagées avec des tiers à des fins commerciales.\n\n'
                  'Un partage peut uniquement avoir lieu dans les cas suivants :\n'
                  '• Obligations légales.\n'
                  '• Demande explicite de l’utilisateur (export de données).\n'
                  '• Prévention de fraude ou activité illégale.',
            ),

            _buildSection(
              context: context,
              title: '7. Droits des utilisateurs',
              icon: Icons.gavel_outlined,
              content:
                  'Conformément aux bonnes pratiques et aux lois applicables, vous disposez des droits suivants :\n\n'
                  '• Accéder à vos données.\n'
                  '• Corriger vos informations.\n'
                  '• Supprimer votre compte.\n'
                  '• Exporter vos données.\n\n'
                  'Ces droits peuvent être exercés directement depuis l’application ou via le support.',
            ),

            _buildSection(
              context: context,
              title: '8. Durée de conservation',
              icon: Icons.access_time_outlined,
              content:
                  'Les données sont conservées tant que le compte est actif.\n\n'
                  'En cas de suppression du compte, les données sont supprimées ou anonymisées, '
                  'sauf obligation légale contraire.',
            ),

            _buildSection(
              context: context,
              title: '9. Modifications de la politique',
              icon: Icons.update_outlined,
              content:
                  'Cette politique peut être mise à jour pour refléter des évolutions légales ou techniques.\n\n'
                  'Toute modification importante sera notifiée à l’utilisateur.\n\n'
                  'Dernière mise à jour : ${_getFormattedDate()}',
            ),

            const SizedBox(height: 30),
            _buildDisclaimer(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Politique de Confidentialité',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(
              context,
            ).primaryColor, // ✅ Utilise la couleur du thème
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Application de Gestion des Transactions Mobile Money\nBurkina Faso',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).hintColor, // ✅ Utilise la couleur du thème
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dernière mise à jour : ${_getFormattedDate()}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor, // ✅ Utilise la couleur du thème
            fontStyle: FontStyle.italic,
          ),
        ),
        const Divider(height: 40, thickness: 1),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Theme.of(context).cardColor, // ✅ S'adapte au thème
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor, // ✅ S'adapte au thème
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).primaryColor, // ✅ S'adapte au thème
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface, // ✅ S'adapte au thème
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.orange.withOpacity(0.1) // Version sombre
            : Colors.blue[50], // Version claire
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.orange.withOpacity(0.3)
              : Colors.blue[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              const SizedBox(width: 10),
              Text(
                'Important',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Cette application est un outil de gestion et ne constitue pas un service bancaire. '
            'Les transactions doivent être effectuées via les canaux officiels des opérateurs (Orange, Moov, etc.). '
            'Gardez toujours vos identifiants confidentiels et signalez toute activité suspecte.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface, // ✅ S'adapte au thème
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Conforme aux lois du Burkina Faso',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor, // ✅ S'adapte au thème
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}



