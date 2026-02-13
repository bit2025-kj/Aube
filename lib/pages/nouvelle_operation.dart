import 'dart:io';
import 'dart:ui';
import 'package:aube/main.dart';
import 'package:aube/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:aube/pages/saisie_manuel.dart';
import 'package:aube/database/database.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class NouvelleOperation extends StatefulWidget {
  const NouvelleOperation({super.key});

  @override
  State<NouvelleOperation> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<NouvelleOperation> {
  final db = AppDatabase();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  File? _capturedImage;
  bool _isProcessing = false;
  Map<String, String> _cnibData = {};
  String _selectedType = 'Retrait';
  String? _selectedOperateur;
  final TextEditingController _numeroDeTelephoneController =
      TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final ValueNotifier<String?> _operateurNotifier = ValueNotifier(null);

  late CameraController _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;

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

  @override
  void dispose() {
    if (_isCameraReady) _cameraController.dispose();
    _textRecognizer.close();
    _montantController.dispose();
    _numeroDeTelephoneController.dispose();
    _operateurNotifier.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isCameraReady) return;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune caméra détectée')),
          );
        }
        return;
      }
      _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
      await _cameraController.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur caméra: $e')));
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile image = await _cameraController.takePicture();
      setState(() {
        _capturedImage = File(image.path);
        _isProcessing = true;
      });
      await _processImage(image.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur capture: $e')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _isProcessing = true;
        });
        await _processImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur capture: $e')));
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      setState(() {
        _cnibData = _parseCNIBData(recognizedText.text);
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur OCR: $e')));
    }
  }

  // NUMERO: recherche avec plusieurs heuristiques
  Map<String, String> _parseCNIBData(String text) {
    final data = <String, String>{};
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String numero = '';
    for (final line in lines) {
      final cnibMatch = RegExp(
        r'\bB\d{6,12}\b',
        caseSensitive: false,
      ).firstMatch(line);
      if (cnibMatch != null) {
        numero = cnibMatch.group(0)!;
        break;
      }
    }

    String nom = '';
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      if (line.toUpperCase().contains(
            RegExp(r'nom|name', caseSensitive: false),
          ) ||
          RegExp(r'^[A-Z\s]{5,}$').hasMatch(line)) {
        nom = line
            .replaceAll(RegExp(r'nom[:\s]*', caseSensitive: false), '')
            .trim();
        break;
      }
    }

    String prenom = '';
    for (int i = 0; i < lines.length && i < 10; i++) {
      final line = lines[i];
      if (line.toUpperCase().contains(
            RegExp(r'prenoms|prénoms|firstname', caseSensitive: false),
          ) ||
          (RegExp(r'^[A-Z\s]{3,}$').hasMatch(line) &&
              !line.toUpperCase().contains(
                RegExp(r'nom|name', caseSensitive: false),
              ))) {
        prenom = line
            .replaceAll(RegExp(r'[:\s]+'), ' ')
            .replaceAll(
              RegExp(r'prenoms|prénoms|firstname', caseSensitive: false),
              '',
            )
            .trim();
        break;
      }
    }

    // DATE DE PEREMPTION: chercher autour de mots-clés puis fallback sur tout le texte
    String dateDePeremption = '';
    final fullText = text.replaceAll(RegExp(r'\s+'), ' ');

    final List<RegExp> datePatterns = [
      RegExp(r'(\d{2}[\/\-\.\s]\d{2}[\/\-\.\s]\d{4})'), // jj/mm/aaaa
      RegExp(r'(\d{4}[\/\-\.\s]\d{2}[\/\-\.\s]\d{2})'), // aaaa/mm/jj
      RegExp(r'(\d{2}[\/\-\.\s]\d{2}[\/\-\.\s]\d{2})'), // jj/mm/aa
      RegExp(
        r'(\d{1,2}\s+(?:janvier|février|fevrier|mars|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+\d{4})',
        caseSensitive: false,
      ),
    ];

    final expiryKeywords = RegExp(
      r'(expire le|Expire le|Expire|valable jusqu|expir|exp|expiry)',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (expiryKeywords.hasMatch(line)) {
        // cherche date sur la même ligne
        for (final pat in datePatterns) {
          final m = pat.firstMatch(line);
          if (m != null) {
            dateDePeremption = m.group(0)!;
            break;
          }
        }
        if (dateDePeremption.isNotEmpty) break;

        // sinon regarde la ligne suivante
        if (i + 1 < lines.length) {
          final next = lines[i + 1];
          for (final pat in datePatterns) {
            final m = pat.firstMatch(next);
            if (m != null) {
              dateDePeremption = m.group(0)!;
              break;
            }
          }
          if (dateDePeremption.isNotEmpty) break;
        }
      }
    }

    // fallback: cherche une date partout dans le texte
    if (dateDePeremption.isEmpty) {
      for (final pat in datePatterns) {
        final m = pat.firstMatch(fullText);
        if (m != null) {
          dateDePeremption = m.group(0)!;
          break;
        }
      }
    }

    data['numero'] = numero;
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['dateDePeremption'] = dateDePeremption;

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text(
          'Scanner CNIB',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManualEntryPage()),
            ),
            child: const Text(
              "MANUEL",
              style: TextStyle(
                color: purpleRoyal,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      body: _capturedImage == null
          ? FutureBuilder(
              future: _initializeCamera(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingCamera();
                }
                return _buildCameraPicker();
              },
            )
          : _isProcessing
          ? _buildProcessing()
          : _buildCNIBResults(),
    );
  }

  Widget _buildLoadingCamera() =>
      const Center(child: CircularProgressIndicator(color: purpleRoyal));

  Widget _buildCameraPicker() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [purpleRoyal, purpleElectric],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            children: [
              Icon(Icons.badge_rounded, color: Colors.white, size: 36),
              SizedBox(height: 12),
              Text(
                'Alignement CNIB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Positionnez la carte dans le cadre',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isCameraReady) CameraPreview(_cameraController),
              Container(
                width: 300,
                height: 450,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              Positioned(
                bottom: 50,
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [purpleRoyal, purpleElectric],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: purpleRoyal.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                right: 50,
                child: IconButton(
                  icon: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: purpleRoyal),
        SizedBox(height: 24),
        Text(
          'Analyse en cours...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _buildCNIBResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: luxuryShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _capturedImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "INFOS DÉTECTÉES",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDataFields(),
                const SizedBox(height: 32),
                _buildLuxuryInput(
                  _montantController,
                  "Montant de l'opération",
                  Icons.account_balance_wallet_rounded,
                ),
                const SizedBox(height: 20),
                _buildLuxuryInput(
                  _numeroDeTelephoneController,
                  "Numéro de téléphone",
                  Icons.phone_android_rounded,
                ),
                const SizedBox(height: 32),
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
                    onPressed: _enregistrerScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text(
                      'CONFIRMER & ENREGISTRER',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _capturedImage = null),
                    child: const Text(
                      "ANNULER LE SCAN",
                      style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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
    );
  }

  Widget _buildLuxuryInput(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: purpleRoyal, size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOperatorRow() {
    return ValueListenableBuilder<String?>(
      valueListenable: _operateurNotifier,
      builder: (context, selectedOperateur, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['orange', 'moov', 'telecel', 'coris', 'sank'].map((op) {
            final bool isSelected = selectedOperateur == op;
            return GestureDetector(
              onTap: () => _operateurNotifier.value = op,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            purpleRoyal.withOpacity(0.15),
                            purpleElectric.withOpacity(0.15),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: purpleElectric, width: 2)
                      : null,
                ),

                child: Image.asset(
                  "assets/images/$op.png",
                  width: 32,
                  height: 32,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDataFields() {
    return Column(
      children: [
        _miniDataField('N° PIÈCE', _cnibData['numero'] ?? '---'),
        _miniDataField('NOM', _cnibData['nom'] ?? '---'),
        _miniDataField('PRÉNOM', _cnibData['prenom'] ?? '---'),
        _miniDataField(
          'Date de Délivrance',
          _cnibData['dateDePeremption'] ?? '---',
        ),
      ],
    );
  }

  Widget _miniDataField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enregistrerScan() async {
    if (_cnibData['numero'] == null || _cnibData['numero']!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Numéro requis')));
      return;
    }

    // Vérification de l'opérateur
    if (_operateurNotifier.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Veuillez sélectionner un opérateur')),
      );
      return;
    }

    final montant = double.tryParse(_montantController.text) ?? 0.0;

    await db
        .into(db.coinsTable)
        .insert(
          CoinsTableCompanion.insert(
            nom: _cnibData['nom'] ?? '',
            prenom: _cnibData['prenom'] ?? '',
            typeDePiece: 'CNIB',
            numeroDePiece: _cnibData['numero']!,
            dateDePeremption: DateTime.now().add(const Duration(days: 3650)),
            typeDeTransaction: _selectedType,
            montant: montant,
            operateur: _operateurNotifier.value!,
            numeroDeTelephone: _numeroDeTelephoneController.text.trim(),
            dateDeTransaction: DateTime.now(),
          ),
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}



