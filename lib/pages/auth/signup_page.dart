import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aube/services/auth_service.dart';
import 'package:aube/services/device_service.dart';
import 'package:aube/services/subscription_service.dart';
import 'package:aube/pages/home.dart';
import 'package:aube/pages/auth/subscription_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }
    // Validation simple du format international
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Format invalide (ex: +33612345678)';
    }
    return null;
  }

  Future<void> _signup() async {
    // Validation
    final phoneError = _validatePhoneNumber(_phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneError)),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe est obligatoire')),
      );
      return;
    }

    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 8 caractères')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final deviceService = Provider.of<DeviceService>(context, listen: false);
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);

      // 1. Signup (and automatic login)
      await authService.signup(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        fullName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
      );

      // 2. Register Device
      await deviceService.registerCurrentDevice();

      // 3. Check Subscription (likely none for new user)
      final subscription = await subscriptionService.getMySubscription();
      final isActive = subscriptionService.isSubscriptionActive(subscription);

      if (!mounted) return;

      if (isActive) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone *',
                  hintText: '+33612345678',
                  helperText: 'Format international obligatoire',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe *',
                  helperText: 'Au moins 8 caractères',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optionnel)',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet (optionnel)',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '* Champs obligatoires',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('S\'inscrire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


