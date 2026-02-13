import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aube/services/subscription_service.dart';
import 'package:aube/pages/home.dart';
import 'dart:developer' as developer;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  String? _activationKey;
  String? _subscriptionStatus;

  
@override
void initState() {
  super.initState();

  // Vérifie le statut après que le widget soit monté
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkCurrentStatus();
  });
}


  Future<void> _checkCurrentStatus() async {
  setState(() => _isLoading = true);
  try {
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    final sub = await subscriptionService.getMySubscription();

    if (sub != null) {
      setState(() {
        _activationKey = sub.activationKey;
        _subscriptionStatus = sub.status;
      });

      if (subscriptionService.isSubscriptionActive(sub)) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  } catch (e) {
    developer.log('Error checking status', name: 'SubscriptionScreen', error: e);
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  Future<void> _subscribe(String planName, int months) async {
    setState(() => _isLoading = true);
    
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      
      // Calculer le montant et la durée en fonction du plan
      double amount;
      int durationDays;
      
      switch (planName) {
        case 'monthly':
          amount = 9.99 * months;
          durationDays = 30 * months;
          break;
        case 'quarterly':
          amount = 24.99;
          durationDays = 90;
          months = 3;
          break;
        case 'yearly':
          amount = 89.99;
          durationDays = 365;
          months = 12;
          break;
        default:
          amount = 9.99;
          durationDays = 30;
          months = 1;
      }
      
      // Demander le numéro de téléphone
      final phoneNumber = await _showPhoneNumberDialog();
      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro de téléphone requis')),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      developer.log('Requesting subscription: $planName, $months months', name: 'SubscriptionScreen');
      
      final subscription = await subscriptionService.requestSubscription(
        phoneNumber: phoneNumber,
        months: months,
        planName: planName,
        amount: amount,
        durationDays: durationDays,
      );
      
      setState(() {
        _activationKey = subscription.activationKey;
        _subscriptionStatus = subscription.status;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Demande d\'abonnement envoyée !\n'
            'Clé d\'activation: ${subscription.activationKey}\n'
            'Statut: ${subscription.status}'
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      
      // Afficher la clé d'activation dans un dialog
      _showActivationKeyDialog(subscription.activationKey);
          
    } catch (e) {
      developer.log('Error requesting subscription', name: 'SubscriptionScreen', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showPhoneNumberDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Numéro de téléphone'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '+226XXXXXXXX',
            labelText: 'Numéro (format international)',
            helperText: 'Ex: +22670123456',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showActivationKeyDialog(String activationKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Clé d\'activation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Votre demande d\'abonnement a été créée avec succès.\n\n'
              'Clé d\'activation:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                activationKey,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Communiquez cette clé à l\'administrateur pour validation.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
 Future<void> _checkStatus() async {
  setState(() => _isLoading = true);
  try {
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    final sub = await subscriptionService.getMySubscription();
    
    if (sub != null) {
      setState(() {
        _activationKey = sub.activationKey;
        _subscriptionStatus = sub.status;
      });

      if (subscriptionService.isSubscriptionActive(sub)) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abonnement activé ! Redirection...'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut: $_subscriptionStatus - En attente de validation...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun abonnement trouvé')),
      );
    }
  } catch (e) {
    developer.log('Error checking status', name: 'SubscriptionScreen', error: e);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: ${e.toString()}')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement Requis'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.lock_outline, size: 80, color: Colors.orange),
                    const SizedBox(height: 24),
                    const Text(
                      'Accès Bloqué',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vous devez avoir un abonnement actif pour accéder à cette application.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    
                    // Afficher le statut actuel si disponible
                    if (_subscriptionStatus != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _subscriptionStatus == 'validated' 
                              ? Colors.green[100] 
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Statut: ${_subscriptionStatus?.toUpperCase()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _subscriptionStatus == 'validated' 
                                    ? Colors.green[900] 
                                    : Colors.orange[900],
                              ),
                            ),
                            if (_activationKey != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Clé: $_activationKey',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 48),
                    const Text(
                      'Choisissez votre plan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Plan Mensuel
                    _buildPlanCard(
                      title: 'Mensuel',
                      price: '9.99 €',
                      period: 'par mois',
                      features: ['Accès complet', 'Support 24/7', '1 appareil'],
                      onTap: () => _subscribe('monthly', 1),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Plan Trimestriel
                    _buildPlanCard(
                      title: 'Trimestriel',
                      price: '24.99 €',
                      period: '3 mois',
                      features: ['Accès complet', 'Support 24/7', '1 appareil', 'Économisez 15%'],
                      onTap: () => _subscribe('quarterly', 3),
                      recommended: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Plan Annuel
                    _buildPlanCard(
                      title: 'Annuel',
                      price: '89.99 €',
                      period: 'par an',
                      features: ['Accès complet', 'Support 24/7', '1 appareil', 'Économisez 25%'],
                      onTap: () => _subscribe('yearly', 12),
                    ),
                    
                    const SizedBox(height: 32),
                    TextButton.icon(
                      onPressed: _checkStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Vérifier mon statut'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onTap,
    bool recommended = false,
  }) {
    return Card(
      elevation: recommended ? 8 : 2,
      color: recommended ? Colors.blue[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: recommended ? Colors.blue[900] : null,
                    ),
                  ),
                  if (recommended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'RECOMMANDÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: recommended ? Colors.blue[900] : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: recommended ? Colors.blue : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: recommended ? Colors.blue : null,
                  ),
                  child: const Text('Choisir ce plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


