import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aube/theme_manager.dart';

class SubscriptionTermsPage extends StatelessWidget {
  const SubscriptionTermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Conditions d'utilisation",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFF3A4F7A),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Container(
            color: isDark ? Color(0xFF121212) : Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF1E1E1E) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(0xFF3A4F7A).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: Color(0xFF3A4F7A),
                          size: 40,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "VisioTransact",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Version 1.0.0 • Mise à jour: Janvier 2026",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Section 1: Introduction
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.info_outline,
                    title: "1. Introduction",
                    content:
                        "Bienvenue sur VisioTransact. En utilisant notre application, vous acceptez les présentes conditions d'utilisation. Veuillez les lire attentivement avant de créer votre compte.",
                  ),

                  // Section 2: Compte utilisateur
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.person_outline,
                    title: "2. Compte Utilisateur",
                    content:
                        "Pour utiliser VisioTransact, vous devez créer un compte en fournissant des informations exactes et complètes. Vous êtes responsable de la confidentialité de votre mot de passe et de toutes les activités effectuées sous votre compte.",
                  ),

                  // Section 3: Utilisation de l'application
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.phone_android,
                    title: "3. Utilisation de l'Application",
                    content:
                        "VisioTransact est conçue pour la gestion de vos transactions financières. Vous vous engagez à utiliser l'application de manière légale et conformément aux lois en vigueur dans votre pays.",
                  ),

                  // Section 4: Protection des données
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.security,
                    title: "4. Protection des Données",
                    content:
                        "Nous prenons la sécurité de vos données très au sérieux. Toutes les informations personnelles et financières sont stockées de manière sécurisée et cryptée. Nous ne partageons jamais vos données avec des tiers sans votre consentement explicite.",
                  ),

                  // Section 5: Abonnement
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.payment,
                    title: "5. Abonnement et Paiement",
                    content:
                        "L'utilisation de certaines fonctionnalités de VisioTransact nécessite un abonnement payant. Les détails de tarification sont disponibles dans l'application. Le renouvellement de l'abonnement se fait automatiquement sauf annulation de votre part.",
                  ),

                  // Section 6: Responsabilités
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.gavel,
                    title: "6. Responsabilités",
                    content:
                        "Vous êtes seul responsable de l'exactitude des informations que vous saisissez dans l'application. VisioTransact ne peut être tenu responsable des erreurs de saisie ou de la mauvaise utilisation de l'application.",
                  ),

                  // Section 7: Propriété intellectuelle
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.copyright,
                    title: "7. Propriété Intellectuelle",
                    content:
                        "Tous les droits de propriété intellectuelle relatifs à VisioTransact, y compris le code, le design, les logos et les contenus, appartiennent exclusivement à leurs propriétaires respectifs.",
                  ),

                  // Section 8: Modifications
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.update,
                    title: "8. Modifications des Conditions",
                    content:
                        "Nous nous réservons le droit de modifier ces conditions d'utilisation à tout moment. Les utilisateurs seront informés de tout changement significatif. L'utilisation continue de l'application après modification vaut acceptation des nouvelles conditions.",
                  ),

                  // Section 9: Résiliation
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.cancel,
                    title: "9. Résiliation",
                    content:
                        "Vous pouvez résilier votre compte à tout moment en nous contactant. Nous nous réservons également le droit de suspendre ou de résilier votre compte en cas de violation de ces conditions.",
                  ),

                  // Section 10: Contact
                  _buildSection(
                    isDark: isDark,
                    icon: Icons.contact_support,
                    title: "10. Nous Contacter",
                    content:
                        "Pour toute question concernant ces conditions d'utilisation, vous pouvez nous contacter via la section 'Contactez-nous' de l'application ou par email à support@visiotransact.com",
                  ),

                  SizedBox(height: 30),

                  // Footer
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF1E1E1E) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Date d'entrée en vigueur : 1er Janvier 2026",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Bouton d'acceptation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3A4F7A),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "J'ai lu et compris",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF3A4F7A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF3A4F7A),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}


