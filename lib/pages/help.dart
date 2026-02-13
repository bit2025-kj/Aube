import 'package:aube/pages/contacts.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Guide d\'utilisation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Introduction
            _buildHelpSection(
              context: context,
              title: ' Bienvenue sur VisioTransact !',
              content: '''
ATTENTION IMPORTANT : Cette application NE FAIT PAS les transactions Orange Money/Moov Money.

C\'EST QUOI ?
C\'est un registre numérique qui vous aide à :
Remplacer vos cahiers papier
Digitaliser le suivi de vos transactions
 Conserver une trace sécurisée des opérations
 Scanner les documents d\'identité des clients
 Générer des statistiques automatiques

À QUOI ÇA SERT ?
→ Enregistrer les transactions APRÈS les avoir faites via Orange/Moov
→ Garder une archive numérique de toutes vos opérations
→ Faciliter votre comptabilité et suivi quotidien
              ''',
            ),

            // Section 2: Clarification importante
            _buildHelpSection(
              context: context,
              title:
                  '⚠️ ATTENTION : Ce n\'est PAS un portefeuille électronique',
              content: '''
CE QUE L\'APP FAIT :
 Enregistre les informations des transactions
 Scan des documents clients
 Statistiques et rapports
 Historique digitalisé
 Calcul des commissions

CE QUE L\'APP NE FAIT PAS :
❌ Envoi d\'argent
❌ Réception d\'argent
❌ Consultation de solde Orange/Moov
❌ Paiement de factures
❌ Recharge de crédit

VOUS DEVEZ TOUJOURS :
1. Faire la transaction via l\'application Orange Money ou Moov Money
2. Puis enregistrer la transaction dans CETTE application
3. Garder les reçus officiels des opérateurs
              ''',
            ),

            // Section 3: Configuration initiale
            _buildHelpSection(
              context: context,
              title: '⚙️ Configuration initiale',
              content: '''
ÉTAPE 1 : Connexion internet requise UNE SEULE FOIS
- Créer votre compte agent
- Configurer vos paramètres
- Télécharger les données initiales

ÉTAPE 2 : Après configuration
Fonctionne COMPLÈTEMENT hors ligne
Toutes les données stockées sur votre téléphone
Pas besoin d\'internet pour enregistrer
Synchronisation automatique quand réseau disponible

Conseil :Configurez tout chez vous avec WiFi avant d\'aller sur le terrain.
              ''',
            ),

            // Section 4: Processus d'enregistrement
            _buildHelpSection(
              context: context,
              title: ' Comment enregistrer une transaction',
              content: '''
APRÈS avoir effectué la transaction avec Orange/Moov :

1. Ouvrez notre application :
   → Acceuil → "Nouvelle opération"

2. Renseignez les informations :
   - Type : Dépôt ou Retrait
   - Opérateur : Orange ou Moov...
   - Montant exact
   

3. Client :
   - Scan du document d\'identité (CNIB)
   - OU saisie manuelle des informations

4. Sauvegarde :
   → La transaction est enregistrée dans l\'historique
   → Disponible même hors ligne
              ''',
            ),

            // Section 5: Scanner documents
            _buildHelpSection(
              context: context,
              title: ' Scanner rapidement les documents d\'identité',
              content: '''
Pourquoi scanner ?
- Éviter les erreurs de saisie
- Gagner du temps
- Archive numérique des clients

Documents acceptés :
- Carte nationale d\'identité (CNIB)


Comment scanner :
1. Dans "Nouvelle opération"

2. Positionnez le document
3. Capture automatique des infos

Les données restent sur votre téléphone uniquement.
              ''',
            ),

            // Section 6: Statistiques et historique
            _buildHelpSection(
              context: context,
              title: ' Statistiques Et Historique De Vos Transactions',
              content: '''
1. Statistiques :
- Nombre de transactions par jour/semaine/mois
- Répartition Orange vs Moov
- Total des montants traités
- Commissions cumulées
- Graphiques visuels

2. Historique :
- Toutes les transactions enregistrées
- Recherche par client ou date
- Filtres avancés
- Export PDF pour comptabilité

3. Rapports :
- Génération automatique
- Format lisible
- Partage facile
              ''',
            ),

            // Section 7: Avantages vs cahier papier
            _buildHelpSection(
              context: context,
              title: ' Avantages de son utilisation  VS cahier papier',
              content: '''
VANTAGES DU NUMÉRIQUE :
Pas de perte de données
Recherche instantanée
Pas de pages déchirées
Calculs automatiques
Sauvegarde sécurisée
 Pas d\'erreur de calcul
Accessible partout
 Économie de papier

PAS BESOIN D\'INTERNET :
- Une fois configuré, tout fonctionne offline
- Pas de frais de données
- Idéal zones faible couverture
              ''',
            ),

            // Section 8: Problèmes techniques
            _buildHelpSection(
              context: context,
              title: '🔧 En cas de problèmes',
              content: '''
Problème courant : "J\'ai oublié d\'enregistrer une transaction"
→ Ajoutez-la après coup avec la bonne date

Problème : Scan ne fonctionne pas
→ Saisissez manuellement
→ Améliorez l\'éclairage
→ Contactez-nous si persiste

Problème : Données affichées incorrectes
→ Vérifiez vos saisies
→ Consultez l\'historique
→ Contactez le support

IMPORTANT : Continuez à garder vos reçus Orange/Moov en parallèle.
              ''',
            ),

            // Section 10: Conseils sécurité
            _buildHelpSection(
              context: context,
              title: '🔒 Sécurité Et  Bonnes Pratiques avec Nous',
              content: '''
1. Double sauvegarde :
- L'application sauvegarde automatiquement
- Exportez régulièrement en PDF
- Envoyez-vous les rapports par email

2. Protection des données :
- Mot de passe fort recommandé
- Ne partagez pas votre compte
- Verrouillez votre téléphone

3. En cas de problème :
→ Ne supprimez pas l\'app
→ Contactez d\'abord le support
→ Sauvegardez manuellement vos données

4. Rappel important :
⚠️ Cette app est un REGISTRE, pas un portefeuille
⚠️ Gardez toujours les reçus officiels
⚠️ Vérifiez vos soldes via les apps officielles
              ''',
            ),

            const SizedBox(height: 30),
            _buildImportantNotice(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required BuildContext context,
    required String title,
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
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor, // ✅ S'adapte au thème
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface, // ✅ S'adapte au thème
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNotice(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.red.withOpacity(0.1) // Version sombre
            : Colors.red[50], // Version claire
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode ? Colors.red.withOpacity(0.3) : Colors.red[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'INFORMATIONS TRÈS IMPORTANTES',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoticeItem(
                context: context,
                icon: Icons.money_off,
                text: 'Cette application NE TRANSFÈRE PAS d\'argent',
              ),
              _buildNoticeItem(
                context: context,
                icon: Icons.phone_android,
                text: 'Les transactions se font via Orange Money / Moov Money',
              ),
              _buildNoticeItem(
                context: context,
                icon: Icons.book,
                text: 'C\'est un REGISTRE NUMÉRIQUE pour remplacer vos cahiers',
              ),
              _buildNoticeItem(
                context: context,
                icon: Icons.save,
                text: 'Enregistrez APRÈS chaque transaction effectuée',
              ),
              _buildNoticeItem(
                context: context,
                icon: Icons.receipt,
                text: 'Gardez TOUJOURS les reçus officiels des opérateurs',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.red.withOpacity(0.5)),
          const SizedBox(height: 15),
          Text(
            'Problème technique ? Question sur l\'utilisation ?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).colorScheme.onSurface, // ✅ S'adapte au thème
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Notre équipe est là pour vous aider. Ne restez pas avec des doutes ou des problèmes techniques.',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(
                context,
              ).colorScheme.onSurface, // ✅ S'adapte au thème
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor, // ✅ S'adapte au thème
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.contact_support_outlined),
                  label: const Text('Contactez-nous'),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface, // ✅ S'adapte au thème
              ),
            ),
          ),
        ],
      ),
    );
  }
}



