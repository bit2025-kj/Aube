import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aube/widgets/sync_status_widget.dart';
import 'package:aube/pages/help.dart';
import 'package:aube/pages/passwordSettings.dart';
import 'package:aube/theme_manager.dart';
// Removed duplicate/unused imports

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDarkMode = themeManager.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settings Section (seulement Theme)
            _buildSectionTitle('Settings'),
            _buildMoreList(context),

            // Theme Section
            _buildThemeSection(context, themeManager, isDarkMode),

            // Log Out Button
            const SizedBox(height: 20),
            const SyncStatusWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    ThemeManager themeManager,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          'Theme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            _showThemeChangeDialog(context, value, themeManager);
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        onTap: null,
      ),
    );
  }

  Widget _buildMoreList(BuildContext context) {
    final moreItems = [
      _ListTileItem(
        icon: Icons.person_outline,
        title: 'Profile',
        trailing: Icons.chevron_right,
        onTap: () {
          /*  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          ); */
        },
      ),
      _ListTileItem(
        icon: Icons.lock_outline,
        title: 'Password',
        trailing: Icons.chevron_right,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PasswordSettingsPage(),
            ),
          );
        },
      ),
      _ListTileItem(
        icon: Icons.language_outlined,
        title: 'Changer la Langue',
        trailing: Icons.chevron_right,
        onTap: () {
          // Navigation vers changement de langue
        },
      ),
      _ListTileItem(
        icon: Icons.star_border,
        title: 'Rate & Review',
        trailing: Icons.chevron_right,
        onTap: () {
          // Navigation vers rate & review
        },
      ),
      _ListTileItem(
        icon: Icons.help_outline,
        title: 'Help',
        trailing: Icons.chevron_right,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpPage()),
          );
        },
      ),
    ];

    return _buildListSection(moreItems, context);
  }

  Widget _buildListSection(List<_ListTileItem> items, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: Theme.of(context).primaryColor),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(item.trailing, color: Colors.grey),
                onTap: item.onTap,
              ),
              if (item != items.last)
                const Divider(height: 1, indent: 20, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showThemeChangeDialog(
    BuildContext context,
    bool toDarkMode,
    ThemeManager themeManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          toDarkMode ? 'Activer le mode sombre' : 'Activer le mode clair',
        ),
        content: Text(
          toDarkMode
              ? 'Voulez-vous activer le mode sombre ?'
              : 'Voulez-vous activer le mode clair ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Appel à la méthode pour changer le thème
              if (toDarkMode) {
                themeManager.setThemeMode(ThemeMode.dark);
              } else {
                themeManager.setThemeMode(ThemeMode.light);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    toDarkMode ? 'Mode sombre activé' : 'Mode clair activé',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Activer'), // CORRECTION : texte simple
          ),
        ],
      ),
    );
  }

  /* Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton(
        onPressed: () {
          _showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Log out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
   */
}

class _ListTileItem {
  final IconData icon;
  final String title;
  final IconData trailing;
  final VoidCallback? onTap;

  _ListTileItem({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ListTileItem &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}



