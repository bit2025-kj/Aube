import 'package:aube/services/sync_transactions_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aube/theme_manager.dart';
import 'package:aube/pages/home.dart';
import 'package:aube/pages/auth/login_page.dart';
import 'package:aube/pages/auth/subscription_page.dart';

// Services
import 'package:aube/services/api_service.dart';
import 'package:aube/services/auth_service.dart';
import 'package:aube/services/device_service.dart';
import 'package:aube/services/subscription_service.dart';
import 'package:aube/services/notification_service.dart';
import 'package:aube/services/ad_service.dart';
import 'package:aube/services/websocket_service.dart';
import 'package:aube/services/transactions_service.dart';  // ✅ NOUVEAU
         

// Database
import 'package:aube/database/database.dart';  // ✅ NOUVEAU

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // ✅ Initialize Local Database
  final localDb = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        
        // Core Services
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => localDb),  // ✅ NOUVEAU
        
        // Auth & Device
        ProxyProvider<ApiService, AuthService>(
          update: (_, api, __) => AuthService(api),
        ),
        ProxyProvider<ApiService, DeviceService>(
          update: (_, api, __) => DeviceService(api),
        ),
        
        // Subscription
        ProxyProvider2<ApiService, DeviceService, SubscriptionService>(
          update: (_, api, device, __) => SubscriptionService(api, device),
        ),
        
        // ✅ Transaction & Sync Services (NOUVEAU)
        ProxyProvider<ApiService, TransactionService>(
          update: (_, api, __) => TransactionService(api),
        ),
        ProxyProvider2<TransactionService, AppDatabase, SyncService>(
          update: (_, transactionService, db, __) => SyncService(transactionService, db),
        ),
        
        // Other Services
        Provider(create: (_) => notificationService),
        ProxyProvider<ApiService, AdService>(
          update: (_, api, __) => AdService(api),
        ),
        Provider(create: (_) => WebSocketService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        // --- Luxury Purple Palette ---
        const Color purpleRoyal = Color(0xFF6200EE);
        const Color purpleElectric = Color(0xFFA855F7);
        const Color bgLight = Color(0xFFF8FAFC);
        const Color white = Color(0xFFFFFFFF);
        const Color textPrimary = Color(0xFF1E1B4B);

        return MaterialApp(
          title: 'VisioTransact',
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            primaryColor: purpleRoyal,
            colorScheme: ColorScheme.fromSeed(
              seedColor: purpleRoyal,
              primary: purpleRoyal,
              secondary: purpleElectric,
              surface: white,
             
              background: bgLight,
              onPrimary: white,
              onSurface: textPrimary,
            ),
            scaffoldBackgroundColor: bgLight,
            appBarTheme: const AppBarTheme(
              backgroundColor: bgLight,
              foregroundColor: textPrimary,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            cardTheme: CardThemeData(
              color: white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: purpleRoyal,
                foregroundColor: white,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          themeMode: themeManager.themeMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final subService = Provider.of<SubscriptionService>(context, listen: false);

      final isLoggedIn = await authService.isLoggedIn();

      if (isLoggedIn) {
        // ✅ Démarrer la synchronisation automatique
        final syncService = Provider.of<SyncService>(context, listen: false);
        syncService.startAutoSync();
        debugPrint('🔄 Synchronisation automatique démarrée');

        final sub = await subService.getMySubscription();
        final isActive = subService.isSubscriptionActive(sub);
        
        setState(() {
          _isAuthenticated = true;
          _isSubscribed = isActive;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
        });
      }
    } catch (e) {
      debugPrint('Auth check failed: $e');
      setState(() {
        _isAuthenticated = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // ✅ Arrêter la synchronisation quand l'app se ferme
    if (_isAuthenticated) {
      final syncService = Provider.of<SyncService>(context, listen: false);
      syncService.stopAutoSync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    if (!_isSubscribed) {
      return const SubscriptionScreen();
    }

    return const HomePage();
  }
}