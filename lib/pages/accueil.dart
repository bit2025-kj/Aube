import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:aube/database/database.dart';
import 'package:intl/intl.dart';

class AccueilPage extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const AccueilPage({super.key, this.onSeeAll});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final AppDatabase _database = AppDatabase();

  // Luxury Purple Palette Constants
  static const Color purpleRoyal = Color(0xFF6200EE);
  static const Color purpleElectric = Color(0xFFA855F7);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color accentBlue = Color(0xFF60A5FA);

  // Strict BoxShadow Rule
  static const List<BoxShadow> luxuryShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 10)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildBalanceCard(),
              _buildQuickActions(),
              _buildRecentTransactionsHeader(),
              _buildTransactionList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Balance Card (Royal Gradient)
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [purpleRoyal, purpleElectric],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: purpleRoyal.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Solde Total",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<CoinsTableData>>(
            stream: _database.select(_database.coinsTable).watch(),
            builder: (context, snapshot) {
              final total =
                  snapshot.data?.fold(0.0, (sum, item) => sum + item.montant) ??
                  0.0;
              return Text(
                "${NumberFormat("#,###").format(total)} F",
                style: const TextStyle(
                  color: white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail("Depôt", "", Colors.greenAccent),
              _buildBalanceDetail("Retrait", "", Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 2. Quick Actions (Transparent Glass Style)
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        /* children: [
          _actionButton("Envoyer", Icons.arrow_upward_rounded, purpleRoyal),
          _actionButton("Recevoir", Icons.arrow_downward_rounded, accentPink),
          _actionButton("Échanger", Icons.swap_horiz_rounded, accentBlue),
        ], */
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: luxuryShadow,
          ),
          child: Center(child: Icon(icon, color: color, size: 26)),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 3. Transactions Recent
  Widget _buildRecentTransactionsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 8, 26, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Transactions Récentes",
            style: TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: widget.onSeeAll,
            child: const Text(
              "Voir Tout",
              style: TextStyle(
                color: purpleRoyal,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<CoinsTableData>>(
      stream:
          (_database.select(_database.coinsTable)
                ..orderBy([(t) => OrderingTerm.desc(t.dateDeTransaction)])
                ..limit(15))
              .watch(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text("Aucune transaction"),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final bool isDepot = tx.typeDeTransaction.toLowerCase().contains(
              'dépot',
            );

            return GestureDetector(
              onTap: () => _showTransactionDetails(tx),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: luxuryShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDepot
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isDepot
                            ? Icons.expand_more_rounded
                            : Icons.expand_less_rounded,
                        color: isDepot ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${tx.prenom} ${tx.nom}",
                            style: const TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              'MMM dd, HH:mm',
                            ).format(tx.dateDeTransaction),
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${isDepot ? '+' : '-'}${NumberFormat("#,###").format(tx.montant)}",
                      style: TextStyle(
                        color: isDepot ? Colors.green : textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTransactionDetails(CoinsTableData tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBE2EF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Opération",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${tx.typeDeTransaction} N°${tx.id}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailRow("Client", "${tx.prenom} ${tx.nom}"),
            _buildDetailRow(
              "Montant",
              "${NumberFormat("#,###").format(tx.montant)} F",
            ),
            _buildDetailRow("Opérateur", tx.operateur.toUpperCase()),
            _buildDetailRow("Téléphone", tx.numeroDeTelephone),
            _buildDetailRow(
              "Date de délivrance",
              DateFormat('dd/MM/yyyy HH:mm').format(tx.dateDePeremption),
            ),
            _buildDetailRow("Numero de pièce", tx.numeroDePiece),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purpleRoyal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Fermer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}



