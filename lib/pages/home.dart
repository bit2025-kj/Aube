import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aube/theme_manager.dart';
import 'package:aube/pages/accueil.dart';
import 'package:aube/pages/statistiques.dart';
import 'package:aube/pages/historiques.dart';
import 'package:aube/pages/settings.dart';
import 'package:aube/pages/nouvelle_operation.dart';
import 'package:aube/pages/contacts.dart';
import 'package:aube/pages/privacy.dart';
import 'package:aube/pages/help.dart';
import 'package:aube/services/auth_service.dart';
import 'package:aube/pages/auth/login_page.dart';
import 'package:aube/widgets/ad_banner.dart';

import 'package:aube/services/ad_service.dart';
import 'package:aube/services/notification_service.dart';
import 'package:aube/models/advertisement.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<GlobalKey> _pageKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  late final List<Widget> pages;
  int pageIndex = 0;
  List<Advertisement> _ads = [];

  // Liste des titres pour chaque page
  final List<String> _pageTitles = [
    'Accueil',
    'Statistiques',
    'Historique',
    'Paramètres',
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      AccueilPage(
        key: _pageKeys[0],
        onSeeAll: () => setState(() => pageIndex = 2),
      ),
      StatistiquesPage(key: _pageKeys[1]),
      HistoriquesPage(key: _pageKeys[2]),
      SettingsPage(key: _pageKeys[3]),
    ];
    
    // Load Ads after init
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAds());
  }

  Future<void> _loadAds() async {
    try {
      final adService = Provider.of<AdService>(context, listen: false);
      final notifService = Provider.of<NotificationService>(context, listen: false);
      
      print('🔍 Loading ads in HomePage...');
      final ads = await adService.getAds();
      print('🔍 Ads loaded: ${ads.length}');
      
      if (mounted) {
        setState(() {
          _ads = ads.where((ad) => ad.isActive).toList();
        });
        print('🔍 Active ads to display: ${_ads.length}');

        // Show system notification for the latest ad if available
        if (_ads.isNotEmpty) {
           // Show the first one as a notification
           await notifService.showAdNotification(_ads.first);
        }
      }
    } catch (e) {
      debugPrint("Error loading ads: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          // AppBar avec Drawer
          appBar: AppBar(
            title: Text(_pageTitles[pageIndex]),
            centerTitle: true,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              // Vous pouvez ajouter des actions ici si nécessaire
              IconButton(
                icon: Badge(
                  isLabelVisible: _ads.isNotEmpty,
                  label: Text('${_ads.length}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  _showNotificationsModal(context);
                },
              ),
            ],
          ),

          // Drawer Menu - À personnaliser selon vos besoins
          drawer: _LuxuryDrawer(),

          body: Column(
            children: [
              if (pageIndex == 0 && _ads.isNotEmpty)
                AdBanner(ads: _ads),
              
              Expanded(
                child: IndexedStack(index: pageIndex, children: pages),
              ),
            ],
          ),

          floatingActionButton: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6200EE), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D6200EE),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NouvelleOperation()),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              highlightElevation: 0,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: _LuxuryBottomBar(
            currentIndex: pageIndex,
            onTap: (index) => setState(() => pageIndex = index),
          ),
        );
      },
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications (${_ads.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              if (_ads.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text("Aucune notification pour le moment"),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _ads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final ad = _ads[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6200EE).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_offer_rounded,
                                color: Color(0xFF6200EE),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ad.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ad.message,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                   Text(
                                    "Valide jusqu'au ${ad.endDate.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Widget du Drawer personnalisé - STRUCTURE DE BASE À PERSONNALISER
class _LuxuryDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6200EE), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header du Drawer
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF6200EE),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nom Utilisateur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'email@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items - PERSONNALISEZ CETTE SECTION
            _buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'Accueil',
              onTap: () {
                Navigator.pop(context);
                // Navigation vers accueil si nécessaire
              },
            ),

            _buildDrawerItem(
              icon: Icons.contacts_rounded,
              title: 'Contacts',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsPage()),
                );
              },
            ),

            _buildDrawerItem(
              icon: Icons.settings_rounded,
              title: 'Paramètres',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            _buildDrawerItem(
              icon: Icons.privacy_tip_rounded,
              title: 'Confidentialité',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPage()),
                );
              },
            ),

            const Divider(color: Colors.white24, height: 32, thickness: 1),

            _buildDrawerItem(
              icon: Icons.help_outline_rounded,
              title: 'Aide & Support',
              onTap: () {
                 Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpPage()),
                );
              },
            ),

            _buildDrawerItem(
              icon: Icons.info_outline_rounded,
              title: 'À propos',
              onTap: () {
                Navigator.pop(context);
                // Votre action
              },
            ),

            const Divider(color: Colors.white24, height: 32, thickness: 1),

            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Déconnexion',
              onTap: () async {
                Navigator.pop(context);
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                if (context.mounted) {
                   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

class _LuxuryBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _LuxuryBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.grid_view_rounded, "Accueil"),
          _buildNavItem(1, Icons.bar_chart_rounded, "Stats"),
          const SizedBox(width: 60), // Space for FAB
          _buildNavItem(2, Icons.history_rounded, "Historique"),
          _buildNavItem(3, Icons.settings_rounded, "Profil"),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    bool isSettings = false,
  }) {
    final isSelected = currentIndex == index;
    final Color activePurple = const Color(0xFF6200EE);

    return InkWell(
      onTap: () {
        if (isSettings) {
          // Trigger settings page or similar
          return;
        }
        onTap(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6200EE), Color(0xFFA855F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activePurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}


