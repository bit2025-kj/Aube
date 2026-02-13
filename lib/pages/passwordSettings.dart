import 'package:flutter/material.dart';

class PasswordSettingsPage extends StatefulWidget {
  const PasswordSettingsPage({super.key});

  @override
  State<PasswordSettingsPage> createState() => _PasswordSettingsPageState();
}

class _PasswordSettingsPageState extends State<PasswordSettingsPage> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Variables pour gérer la visibilité des mots de passe
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Variables pour la validation
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Validation des règles de mot de passe
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Méthode pour valider le nouveau mot de passe
  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // Méthode pour vérifier si tous les critères sont remplis
  bool get _isPasswordValid {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  // Méthode pour changer le mot de passe
  Future<void> _changePassword() async {
    // Validation basique
    if (_currentPasswordController.text.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Veuillez entrer votre mot de passe actuel';
      });
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Veuillez entrer un nouveau mot de passe';
      });
      return;
    }

    if (!_isPasswordValid) {
      setState(() {
        _hasError = true;
        _errorMessage =
            'Le nouveau mot de passe ne respecte pas les critères de sécurité';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Les nouveaux mots de passe ne correspondent pas';
      });
      return;
    }

    // Simuler le chargement
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simuler une requête API
    await Future.delayed(const Duration(seconds: 2));

    // Simuler une réponse (non-const pour éviter dead code lors du développement)
    final bool success =
        DateTime.now().millisecondsSinceEpoch % 2 ==
        0; // alternance temporaire pour tests

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe modifié avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Réinitialiser les champs
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Fermer la page après succès
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _hasError = true;
        _errorMessage =
            'Échec de la modification. Vérifiez votre mot de passe actuel.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le mot de passe'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(),

            // Formulaire
            _buildPasswordForm(),

            // Règles de sécurité
            _buildPasswordRules(),

            // Bouton de validation
            _buildSubmitButton(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Sécurité du compte',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A4F7A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pour la sécurité de vos transactions, choisissez un mot de passe fort.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mot de passe actuel
            TextFormField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF3A4F7A),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nouveau mot de passe
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              onChanged: _validatePassword,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                prefixIcon: const Icon(
                  Icons.lock_reset_outlined,
                  color: Color(0xFF3A4F7A),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirmer le nouveau mot de passe
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                prefixIcon: const Icon(
                  Icons.lock_reset_outlined,
                  color: Color(0xFF3A4F7A),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Message d'erreur
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRules() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Critères de sécurité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A4F7A),
              ),
            ),
            const SizedBox(height: 12),
            _buildRuleItem(
              isValid: _hasMinLength,
              text: 'Au moins 8 caractères',
            ),
            _buildRuleItem(
              isValid: _hasUppercase,
              text: 'Au moins une majuscule (A-Z)',
            ),
            _buildRuleItem(
              isValid: _hasLowercase,
              text: 'Au moins une minuscule (a-z)',
            ),
            _buildRuleItem(
              isValid: _hasNumber,
              text: 'Au moins un chiffre (0-9)',
            ),
            _buildRuleItem(
              isValid: _hasSpecialChar,
              text: 'Au moins un caractère spécial (!@#\$...)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem({required bool isValid, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A4F7A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.blue.withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'MODIFIER LE MOT DE PASSE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }
}



