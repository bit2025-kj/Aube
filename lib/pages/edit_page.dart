import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:aube/database/database.dart';
import 'package:intl/intl.dart';

class EditPage extends StatefulWidget {
  final int coinId; // ✅ ID obligatoire pour édition

  const EditPage({super.key, required this.coinId});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final AppDatabase _database = AppDatabase();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final _nomController = TextEditingController();
  late final _prenomController = TextEditingController();
  late final _typePieceController = TextEditingController();
  late final _numeroPieceController = TextEditingController();
  late final _datePeremptionController = TextEditingController();
  late final _montantController = TextEditingController();
  late final _numeroDeTelephoneController = TextEditingController();

  String _selectedType = 'Retrait';
  String _selectedOperateur = 'orange';

  static const Color bleuPrimaire = Color(0xFF3A4F7A);
  static const Color noirSecondaire = Color(0xFF1C1C1C);

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    // ✅ CHARGER transaction par ID
    final coin = await (_database.select(
      _database.coinsTable,
    )..where((tbl) => tbl.id.equals(widget.coinId))).getSingleOrNull();

    if (coin != null && mounted) {
      _nomController.text = coin.nom;
      _prenomController.text = coin.prenom;
      _typePieceController.text = coin.typeDePiece;
      _numeroPieceController.text = coin.numeroDePiece;
      _datePeremptionController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(coin.dateDePeremption);
      _montantController.text = coin.montant.toString();
      _numeroDeTelephoneController.text = coin.numeroDeTelephone;
      _selectedType = coin.typeDeTransaction;
      _selectedOperateur = coin.operateur;
      setState(() {});
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboard,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isOptional ? ' (Optionnel)' : '*'),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      keyboardType: keyboard,
      validator: (value) {
        if (!isOptional && (value?.isEmpty ?? true)) {
          return 'Champ requis';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier Transaction',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: bleuPrimaire,
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              'SAUVEGARDER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Informations Client",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: noirSecondaire,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Nom", _nomController)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField("Prénom", _prenomController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pièce d'identité
                  Text(
                    "Pièce d'identité",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: noirSecondaire,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          "Type de pièce",
                          _typePieceController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          "Numéro de pièce",
                          _numeroPieceController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _datePeremptionController,
                    decoration: InputDecoration(
                      labelText: "Date péremption (AAAA-MM-JJ) *",
                      hintText: "Ex: 2025-12-31",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Date de péremption requise';
                      try {
                        DateFormat('yyyy-MM-dd').parse(value);
                        return null;
                      } catch (e) {
                        return 'Format invalide. Utilisez AAAA-MM-JJ.';
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Transaction
                  Text(
                    "Transaction",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: noirSecondaire,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Montant",
                    _montantController,
                    keyboard: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Téléphone",
                    _numeroDeTelephoneController,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  // Opérateurs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOpImage("assets/images/orange.png", 'orange'),
                      _buildOpImage("assets/images/moov_africa.png", 'moov'),
                      _buildOpImage("assets/images/telecel.png", 'telecel'),
                      _buildOpImage("assets/images/sank.png", 'sank'),
                      _buildOpImage("assets/images/coris.png", 'coris'),
                      _buildOpImage("assets/images/wave.png", 'wave'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Types
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRadioButton('Retrait'),
                      _buildRadioButton('Dépot'),
                      _buildRadioButton('Transfert'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Annuler",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bleuPrimaire,
                          ),
                          child: const Text(
                            "MODIFIER",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpImage(String asset, String operateur) => GestureDetector(
    onTap: () => setState(() => _selectedOperateur = operateur),
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _selectedOperateur == operateur
            ? bleuPrimaire
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: _selectedOperateur == operateur
            ? Border.all(color: bleuPrimaire, width: 2)
            : null,
      ),
      child: Image.asset(
        asset,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      ),
    ),
  );

  Widget _buildRadioButton(String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Radio<String>(
        value: label,
        groupValue: _selectedType,
        onChanged: (value) => setState(() => _selectedType = value!),
        activeColor: bleuPrimaire,
      ),
      Text(label),
    ],
  );

  Future<void> _saveTransaction() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    final now = DateTime.now();
    DateTime datePeremption;

    try {
      datePeremption = DateFormat(
        'yyyy-MM-dd',
      ).parse(_datePeremptionController.text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Format de date invalide')),
        );
      }
      return;
    }

    final transactionCompanion = CoinsTableCompanion(
      nom: Value(_nomController.text.trim()),
      prenom: Value(_prenomController.text.trim()),
      typeDePiece: Value(_typePieceController.text.trim()),
      numeroDePiece: Value(_numeroPieceController.text.trim()),
      dateDePeremption: Value(datePeremption),
      typeDeTransaction: Value(_selectedType),
      montant: Value(double.tryParse(_montantController.text) ?? 0.0),
      operateur: Value(_selectedOperateur),
      numeroDeTelephone: Value(_numeroDeTelephoneController.text.trim()),
      dateDeTransaction: Value(now),
    );

    try {
      // ✅ UPDATE par ID
      await (_database.update(_database.coinsTable)
            ..where((tbl) => tbl.id.equals(widget.coinId)))
          .write(transactionCompanion);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Transaction modifiée')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _typePieceController.dispose();
    _numeroPieceController.dispose();
    _datePeremptionController.dispose();
    _montantController.dispose();
    _numeroDeTelephoneController.dispose();
    super.dispose();
  }
}



