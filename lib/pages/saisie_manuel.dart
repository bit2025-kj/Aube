import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:aube/database/database.dart';

class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  @override
  _ManualEntryPageState createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final AppDatabase db = AppDatabase();

  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _numeroPieceController = TextEditingController();
  String? _selectedTypePiece;
  final _montantController = TextEditingController();
  final _numeroDeTelephoneController = TextEditingController();

  String _selectedType = 'Retrait';
  String _selectedOperateur = 'orange';

  // Luxury Purple Palette
  static const Color purpleRoyal = Color(0xFF6200EE);
  static const Color purpleElectric = Color(0xFFA855F7);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF94A3B8);

  static const List<BoxShadow> luxuryShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 10)),
  ];

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboard,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label + (isOptional ? ' ' : '*'),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      keyboardType: keyboard,
      validator: (value) =>
          (!isOptional && (value?.isEmpty ?? true)) ? 'Requis' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text(
          'Nouvelle Saisie',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        backgroundColor: bgLight,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: luxuryShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "INFORMATIONS CLIENT",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField("Nom", _nomController),
                    const SizedBox(height: 12),
                    _buildTextField("Prénom", _prenomController),
                    const SizedBox(height: 32),
                    const Text(
                      "PIÈCE D'IDENTITÉ",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTypePiece,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: "Type de pièce *",
                        labelStyle: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      items:
                          ['CNIB', 'Passeport', 'Permis', 'Visa', 'GIM-UEMOA']
                              .map(
                                (l) =>
                                    DropdownMenuItem(value: l, child: Text(l)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedTypePiece = v),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Numéro de pièce", _numeroPieceController),
                    const SizedBox(height: 32),
                    const Text(
                      "DÉTAILS TRANSACTION",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      isOptional: true,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "OPÉRATEUR",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOperatorRow(),
                    const SizedBox(height: 24),
                    _buildTypeSelector(),
                    const SizedBox(height: 48),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [purpleRoyal, purpleElectric],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: purpleRoyal.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _enregistrerTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text(
                          'ENREGISTRER L\'OPÉRATION',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['orange', 'moov', 'telecel', 'coris', 'sank'].map((op) {
        final isSelected = _selectedOperateur == op;
        return GestureDetector(
          onTap: () => setState(() => _selectedOperateur = op),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? purpleRoyal : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset("assets/images/$op.png", width: 28, height: 28),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: ['Retrait', 'Dépot', 'Transfert'].map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? purpleRoyal : white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? purpleRoyal : const Color(0xFFF1F5F9),
                ),
              ),
              child: Center(
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? white : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _enregistrerTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    await db
        .into(db.coinsTable)
        .insert(
          CoinsTableCompanion.insert(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            typeDePiece: _selectedTypePiece ?? 'CNIB',
            numeroDePiece: _numeroPieceController.text.trim(),
            dateDePeremption: DateTime.now().add(const Duration(days: 3650)),
            typeDeTransaction: _selectedType,
            montant: double.tryParse(_montantController.text) ?? 0.0,
            operateur: _selectedOperateur,
            numeroDeTelephone: _numeroDeTelephoneController.text.trim(),
            dateDeTransaction: DateTime.now(),
          ),
        );
    Navigator.pop(context);
  }
}



