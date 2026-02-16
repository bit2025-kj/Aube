import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:aube/database/database.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart' as Shareplus;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:aube/services/auth_service.dart';

class HistoriquesPage extends StatefulWidget {
  const HistoriquesPage({super.key});

  @override
  State<HistoriquesPage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquesPage> {
  final AppDatabase _database = AppDatabase();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final id = await authService.getUserId();
    if (mounted) {
      setState(() {
        _userId = id;
      });
    }
  }

  // --- State ---
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedPeriod = 'Tous';
  bool _isExporting = false;

  // Soft Premium Blue Palette
  static const Color bluePrimary = Color(0xFF81A4CD);
  static const Color blueSecondary = Color(0xFF3A4F7A);
  static const Color bgLight = Color(0xFFF7FAFF);
  static const Color white = Colors.white;
  static const Color textMain = Color(0xFF2D3142);
  static const Color purpleRoyal = Color(0xFF6200EE);
  static const Color purpleElectric = Color(0xFFA855F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: StreamBuilder<List<CoinsTableData>>(
        stream: _getFilteredStream(),
        builder: (context, snapshot) {
          final transactions = snapshot.data ?? [];
          final todayStats = _calculateTodayStats(
            allTransactions: transactions,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(todayStats),
              _buildFilterBar(),
              _buildTransactionList(transactions),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> stats) {
    return SliverAppBar(
      expandedHeight: 180,
      collapsedHeight: 80,
      pinned: true,
      elevation: 0,
      backgroundColor: purpleRoyal,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [purpleRoyal, purpleElectric],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TOTAL DU JOUR",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${NumberFormat("#,###").format(stats['total'])} F",
                      style: const TextStyle(
                        color: white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _isExporting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: white,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Iconsax.archive_add, color: white),
                            onPressed: () => _exportToPdf(stats['currentList']),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
        title: const Text(
          "",
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 110.0,
        maxHeight: 110.0,
        child: Container(
          color: bgLight,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: "Rechercher...",
                      prefixIcon: Icon(
                        Iconsax.search_status,
                        size: 18,
                        color: blueSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildFilterChip(
                      "Tous",
                      _selectedPeriod == 'Tous',
                      () => setState(() => _selectedPeriod = 'Tous'),
                    ),
                    _buildFilterChip(
                      "Jour",
                      _selectedPeriod == 'Aujourd’hui',
                      () => setState(() => _selectedPeriod = 'Aujourd’hui'),
                    ),
                    _buildFilterChip(
                      "Mois",
                      _selectedPeriod == 'Mois',
                      () => setState(() => _selectedPeriod = 'Mois'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? purpleRoyal : white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? purpleRoyal : const Color(0xFFDBE2EF),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? white : textMain,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<CoinsTableData> transactions) {
    if (transactions.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("Aucune transaction")),
      );
    }
    final grouped = _groupTransactionsByDateString(transactions);
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final groupTitle = grouped.keys.elementAt(index);
        final groupItems = grouped[groupTitle]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Text(
                groupTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ),
            ...groupItems.map((tx) => _buildTransactionCard(tx)).toList(),
          ],
        );
      }, childCount: grouped.length),
    );
  }

  Widget _buildTransactionCard(CoinsTableData tx) {
    final bool isDepot = tx.typeDeTransaction.toLowerCase().contains('dépot');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Slidable(
        key: ValueKey(tx.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _shareTransaction(tx),
              backgroundColor: purpleRoyal,
              foregroundColor: white,
              icon: Iconsax.share,
              borderRadius: BorderRadius.circular(15),
            ),
            SlidableAction(
              onPressed: (_) => _deleteTransaction(tx),
              backgroundColor: Colors.redAccent,
              foregroundColor: white,
              icon: Iconsax.trash,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _showTransactionDetails(tx),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDepot
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF3F4FB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDepot ? Iconsax.import : Iconsax.export,
                    color: isDepot ? Colors.green : bluePrimary,
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
                          color: textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${DateFormat('HH:mm').format(tx.dateDeTransaction)} • ${tx.operateur.toUpperCase()}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isDepot ? '+' : '-'}${NumberFormat("#,###").format(tx.montant)} F",
                  style: TextStyle(
                    color: isDepot ? Colors.green : textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Logic Helpers ---
  Stream<List<CoinsTableData>> _getFilteredStream() {
    if (_userId == null) return const Stream.empty();
    var query = _database.select(_database.coinsTable)
      ..where((t) => t.userId.equals(_userId!))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateDeTransaction)]);
    return query.watch();
  }

  List<CoinsTableData> _applyUIFilters(List<CoinsTableData> all) {
    return all.where((tx) {
      final matchesSearch =
          tx.nom.toLowerCase().contains(_searchQuery) ||
          tx.prenom.toLowerCase().contains(_searchQuery) ||
          tx.numeroDeTelephone.contains(_searchQuery);
      bool matchesPeriod = true;
      DateTime now = DateTime.now();
      if (_selectedPeriod == 'Aujourd’hui') {
        matchesPeriod =
            tx.dateDeTransaction.year == now.year &&
            tx.dateDeTransaction.month == now.month &&
            tx.dateDeTransaction.day == now.day;
      } else if (_selectedPeriod == 'Mois')
        // ignore: curly_braces_in_flow_control_structures
        matchesPeriod =
            tx.dateDeTransaction.year == now.year &&
            tx.dateDeTransaction.month == now.month;
      return matchesSearch && matchesPeriod;
    }).toList();
  }

  Map<DateTime, List<CoinsTableData>> _groupTransactionsByDate(
    List<CoinsTableData> txs,
  ) {
    final filtered = _applyUIFilters(txs);
    Map<DateTime, List<CoinsTableData>> groups = {};
    for (var tx in filtered) {
      final date = DateTime(
        tx.dateDeTransaction.year,
        tx.dateDeTransaction.month,
        tx.dateDeTransaction.day,
      );
      if (!groups.containsKey(date)) groups[date] = [];
      groups[date]!.add(tx);
    }
    return groups;
  }

  Map<String, List<CoinsTableData>> _groupTransactionsByDateString(
    List<CoinsTableData> txs,
  ) {
    final grouped = _groupTransactionsByDate(txs);
    Map<String, List<CoinsTableData>> result = {};
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    grouped.forEach((date, list) {
      String title =
          (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day)
          ? "Aujourd'hui"
          : (date.year == yesterday.year &&
                date.month == yesterday.month &&
                date.day == yesterday.day)
          ? "Hier"
          : DateFormat('dd MMMM yyyy').format(date);
      result[title] = list;
    });
    return result;
  }

  Map<String, dynamic> _calculateTodayStats({
    required List<CoinsTableData> allTransactions,
  }) {
    DateTime now = DateTime.now();
    final todayList = allTransactions
        .where(
          (tx) =>
              tx.dateDeTransaction.year == now.year &&
              tx.dateDeTransaction.month == now.month &&
              tx.dateDeTransaction.day == now.day,
        )
        .toList();
    return {
      'total': todayList.fold(0.0, (sum, tx) => sum + tx.montant),
      'count': todayList.length,
      'currentList': todayList,
    };
  }

  Future<void> _exportToPdf(List<CoinsTableData> coins) async {
    if (coins.isEmpty) return;
    setState(() => _isExporting = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'VISIOTRANSACT - RÉSUMÉ',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Nom', 'Type', 'Montant', 'Opérateur', 'Date'],
              data: coins
                  .map(
                    (c) => [
                      "${c.prenom} ${c.nom}",
                      c.typeDeTransaction,
                      "${NumberFormat("#,###").format(c.montant)} F",
                      c.operateur.toUpperCase(),
                      DateFormat('dd/MM/yy HH:mm').format(c.dateDeTransaction),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue600,
              ),
            ),
          ],
        ),
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _shareTransaction(CoinsTableData tx) {
    Shareplus.Share.share(
      "Transaction VisioTransact\nClient: ${tx.prenom} ${tx.nom}\nType: ${tx.typeDeTransaction}\nMontant: ${NumberFormat("#,###").format(tx.montant)} F\nOpérateur: ${tx.operateur.toUpperCase()}\nDate: ${DateFormat('dd/MM/yyyy HH:mm').format(tx.dateDeTransaction)}",
    );
  }

  void _deleteTransaction(CoinsTableData tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await _database.deleteCoin(tx.id, tx.userId);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
              style: const TextStyle(
                color: textMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
            style: const TextStyle(
              color: textMain,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}



