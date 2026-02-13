import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgLight = Color(0xFFF7FAFF);
    const Color white = Colors.white;
    const Color textMain = Color(0xFF2D3142);
    const Color bluePrimary = Color(0xFF81A4CD);
    const Color blueSecondary = Color(0xFF3F72AF);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(title: const Text('Support'), elevation: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Contactez-nous',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nous sommes là pour vous aider. Envoyez-nous un message.',
              style: TextStyle(fontSize: 15, color: textMain.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInput(
                    "Nom Complet",
                    Icons.person_outline_rounded,
                    blueSecondary,
                  ),
                  const SizedBox(height: 16),
                  _buildInput("Email", Icons.email_outlined, blueSecondary),
                  const SizedBox(height: 16),
                  _buildInput(
                    "Message",
                    Icons.message_outlined,
                    blueSecondary,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bluePrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'ENVOYER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildContactInfo(white, textMain, bluePrimary, blueSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    IconData icon,
    Color blueSec, {
    int maxLines = 1,
  }) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: blueSec, size: 20),
        filled: true,
        fillColor: const Color(0xFFF7FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildContactInfo(
    Color white,
    Color textMain,
    Color bluePrimary,
    Color blueSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.phone_rounded,
            'Téléphone',
            '+226 54515907',
            bluePrimary,
            blueSecondary,
            textMain,
          ),
          const Divider(height: 32, color: Color(0xFFF0F4F8)),
          _infoRow(
            Icons.email_rounded,
            'Email',
            'support@visiotransact.bf',
            bluePrimary,
            blueSecondary,
            textMain,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color bluePri,
    Color blueSec,
    Color textMain,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bluePri.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: blueSec, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}



