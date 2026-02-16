import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aube/database/database.dart';
import 'package:provider/provider.dart';
import 'package:aube/services/auth_service.dart';

const Color kPrimaryColor = Color(0xFF3A4F7A);
const Color kWhite = Color(0xFFFFFFFF);
const Color kSoftBackground = Color(0xFFF5F7FA);

class MonthlyViewPage extends StatefulWidget {
  const MonthlyViewPage({super.key});

  @override
  @override
  State<MonthlyViewPage> createState() => _MonthlyViewPageState();
}

enum MonthlyFilter { all, depot, retrait, transfert }

class _MonthlyViewPageState extends State<MonthlyViewPage> {
  final AppDatabase _database = AppDatabase();
  MonthlyFilter _monthlyFilter = MonthlyFilter.all;
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

  String formatSolde(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }

  Stream<Map<String, int>> _monthlyStreamFiltered() {
    if (_userId == null) return const Stream.empty();
    switch (_monthlyFilter) {
      case MonthlyFilter.depot:
        return _database
            .countTransactionsByMonth(_userId!); // TODO: ajouter filtre type
      case MonthlyFilter.retrait:
        return _database
            .countTransactionsByMonth(_userId!); // TODO: ajouter filtre type
      case MonthlyFilter.transfert:
        return _database
            .countTransactionsByMonth(_userId!); // TODO: ajouter filtre type
      case MonthlyFilter.all:
        return _database.countTransactionsByMonth(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mois',
          style: TextStyle(color: kWhite, fontWeight: FontWeight.w600),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: kSoftBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildMonthlyChart(),
              const SizedBox(height: 24),
              _buildOperatorsSection(),
              const SizedBox(height: 24),
              _buildTypesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'SOLDE MOIS',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  StreamBuilder<double>(
                    stream: _userId == null ? const Stream.empty() : _database.soldeTotalStream(_userId!),
                    initialData: 0.0,
                    builder: (context, snapshot) => Text(
                      formatSolde(snapshot.data ?? 0),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'TOTAL MOIS',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  StreamBuilder<List<CoinsTableData>>(
                    stream: _userId == null ? const Stream.empty() : _database.watchAllCoins(_userId!),
                    builder: (context, snapshot) {
                      final total = snapshot.data?.length ?? 0;
                      return Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 24,
                          color: kPrimaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    const weeks = ['S1', 'S2', 'S3', 'S4', 'S5']; // ← SEMAINES au lieu de mois

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité par semaine (mois)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ChoiceChip(
          label: const Text('Tous'),
          selected: _monthlyFilter == MonthlyFilter.all,
          onSelected: (_) => setState(() => _monthlyFilter = MonthlyFilter.all),
        ),
        ChoiceChip(
          label: const Text('Dépôt'),
          selected: _monthlyFilter == MonthlyFilter.depot,
          onSelected: (_) =>
              setState(() => _monthlyFilter = MonthlyFilter.depot),
        ),
        ChoiceChip(
          label: const Text('Retrait'),
          selected: _monthlyFilter == MonthlyFilter.retrait,
          onSelected: (_) =>
              setState(() => _monthlyFilter = MonthlyFilter.retrait),
        ),
        ChoiceChip(
          label: const Text('Transfert'),
          selected: _monthlyFilter == MonthlyFilter.transfert,
          onSelected: (_) =>
              setState(() => _monthlyFilter = MonthlyFilter.transfert),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, int>>(
            stream: _monthlyStreamFiltered(),
            initialData: {},
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? {};
              if (data.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune donnée ce mois',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              // 📅 CALCUL SEMAINES DU MOIS COURANT
              final now = DateTime.now();
              final monthStart = DateTime(now.year, now.month, 1);

              final weekCounts = <int, int>{};
              for (int i = 0; i < 5; i++) {
                final weekStart = monthStart.add(Duration(days: i * 7));
                final weekEnd = weekStart.add(const Duration(days: 6));

                final count = data.entries
                    .where((entry) {
                      // Parse "2025-11" → DateTime
                      final parts = entry.key.split('-');
                      if (parts.length != 2) return false;
                      final year = int.parse(parts[0]);
                      final month = int.parse(parts[1]);
                      final date = DateTime(
                        year,
                        month,
                        1,
                      ); // ✅ 1er jour du mois

                      return date.isAfter(
                            weekStart.subtract(const Duration(days: 1)),
                          ) &&
                          date.isBefore(weekEnd);
                    })
                    .fold(0, (sum, e) => sum + e.value);
                weekCounts[i] = count;
              }

              final maxValue =
                  weekCounts.values.reduce((a, b) => a > b ? a : b) + 1;

              final bars = weeks.asMap().entries.map((entry) {
                final index = entry.key;
                final count = weekCounts[index] ?? 0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: Colors.purple,
                      width: 25,
                    ),
                  ],
                );
              }).toList();

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue.toDouble(),
                  barGroups: bars,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weeks[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Types de transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, int>>(
            stream: _userId == null ? const Stream.empty() : _database
                .countTransactionsByMonth(_userId!), // TODO: filtre mois courant
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune donnée',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final data = snapshot.data!;
              final total = data.values.fold(0, (sum, v) => sum + v);

              return Row(
                children: [
                  Expanded(
                    child: _buildTypeCard(
                      'Dépôt',
                      data['Dépot'] ?? 0,
                      total,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeCard(
                      'Retrait',
                      data['Retrait'] ?? 0,
                      total,
                      Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(String label, int count, int total, Color color) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(0)
        : '0';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opérateurs (Mois)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, int>>(
            stream: _userId == null ? const Stream.empty() : _database
                .countTransactionsByMonth(_userId!), // TODO: filtre mois courant
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune donnée',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final data = snapshot.data!;
              final sorted = data.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topOperators = sorted.take(5).toList();

              return Column(
                children: [
                  ...topOperators.map(
                    (entry) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          entry.key[0],
                          style: const TextStyle(color: kWhite),
                        ),
                      ),
                      title: Text(entry.key),
                      trailing: Text(
                        '${entry.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (topOperators.length < 5)
                    const ListTile(
                      title: Text(
                        'Autres...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}



