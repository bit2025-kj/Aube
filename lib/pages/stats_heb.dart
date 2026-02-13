import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:aube/database/database.dart';

const Color kPrimaryColor = Color(0xFF3A4F7A);
const Color kWhite = Color(0xFFFFFFFF);

class WeeklyStatsPage extends StatefulWidget {
  const WeeklyStatsPage({Key? key}) : super(key: key);
  @override
  State<WeeklyStatsPage> createState() => _WeeklyStatsPageState();
}

enum WeeklyOperatorFilter { all, depot, retrait, transfert }

enum WeekTypeFilter { all, depot, retrait, transfert }

class _WeeklyStatsPageState extends State<WeeklyStatsPage> {
  final AppDatabase _database = AppDatabase();

  WeeklyOperatorFilter _weeklyOperatorFilter = WeeklyOperatorFilter.all;
  WeekTypeFilter _weekTypeFilter = WeekTypeFilter.all;

  String formatSolde(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }

  @override
  void initState() {
    super.initState();
    _database.debugWeekData();
  }

  Stream<Map<String, int>> _weeklyOperatorStreamForFilter() {
    switch (_weeklyOperatorFilter) {
      case WeeklyOperatorFilter.depot:
        return _database.countTransactionsByOperatorWeekForType('Dépot');
      case WeeklyOperatorFilter.retrait:
        return _database.countTransactionsByOperatorWeekForType('Retrait');
      case WeeklyOperatorFilter.transfert:
        return _database.countTransactionsByOperatorWeekForType('Transfert');
      case WeeklyOperatorFilter.all:
        return _database.countTransactionsByOperatorWeek();
    }
  }

  Stream<Map<String, int>> _weekDayStreamFiltered() {
    switch (_weekTypeFilter) {
      case WeekTypeFilter.depot:
        return _database.countTransactionsByWeekDay(typeFilter: 'Dépot');
      case WeekTypeFilter.retrait:
        return _database.countTransactionsByWeekDay(typeFilter: 'Retrait');
      case WeekTypeFilter.transfert:
        return _database.countTransactionsByWeekDay(typeFilter: 'Transfert');
      case WeekTypeFilter.all:
        return _database.countTransactionsByWeekDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semaine',
          style: TextStyle(fontWeight: FontWeight.w700, color: kWhite),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildWeekDayChart(),
            const SizedBox(height: 24),
            _buildOperatorsChart(),
            const SizedBox(height: 24),
            _buildTypesChart(),
          ],
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
                    'SOLDE',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  StreamBuilder<double>(
                    stream: _database.soldeTotalStream(),
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
                    'TOTAL',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  StreamBuilder<List<CoinsTableData>>(
                    stream: _database.watchAllCoins(),
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

  Widget _buildWeekDayChart() {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité par jour',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12), // Espacement entre texte et boutons
        Wrap(
          spacing: 8, // espace horizontal entre les chips
          runSpacing: 8, // espace vertical si retour à la ligne
          children: [
            ChoiceChip(
              label: const Text('Tous'),
              selected: _weekTypeFilter == WeekTypeFilter.all,
              onSelected: (_) =>
                  setState(() => _weekTypeFilter = WeekTypeFilter.all),
            ),
            ChoiceChip(
              label: const Text('Dépôt'),
              selected: _weekTypeFilter == WeekTypeFilter.depot,
              onSelected: (_) =>
                  setState(() => _weekTypeFilter = WeekTypeFilter.depot),
            ),
            ChoiceChip(
              label: const Text('Retrait'),
              selected: _weekTypeFilter == WeekTypeFilter.retrait,
              onSelected: (_) =>
                  setState(() => _weekTypeFilter = WeekTypeFilter.retrait),
            ),
            ChoiceChip(
              label: const Text('Transfert'),
              selected: _weekTypeFilter == WeekTypeFilter.transfert,
              onSelected: (_) =>
                  setState(() => _weekTypeFilter = WeekTypeFilter.transfert),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, int>>(
            stream: _weekDayStreamFiltered(),
            initialData: {for (var day in days) day: 0},
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData ||
                  snapshot.data!.values.every((count) => count == 0)) {
                return const Center(
                  child: Text(
                    'Aucune donnée cette semaine',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final data = snapshot.data!;
              final maxValue = data.values.reduce((a, b) => a > b ? a : b) + 1;
              final bars = days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                final count = data[day] ?? 0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: Colors.blue,
                      width: 20,
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 12),
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

  Widget _buildOperatorsChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opérateurs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ChoiceChip(
              label: const Text('Tous'),
              selected: _weeklyOperatorFilter == WeeklyOperatorFilter.all,
              onSelected: (_) => setState(
                () => _weeklyOperatorFilter = WeeklyOperatorFilter.all,
              ),
            ),
            ChoiceChip(
              label: const Text('Dépôt'),
              selected: _weeklyOperatorFilter == WeeklyOperatorFilter.depot,
              onSelected: (_) => setState(
                () => _weeklyOperatorFilter = WeeklyOperatorFilter.depot,
              ),
            ),
            ChoiceChip(
              label: const Text('Retrait'),
              selected: _weeklyOperatorFilter == WeeklyOperatorFilter.retrait,
              onSelected: (_) => setState(
                () => _weeklyOperatorFilter = WeeklyOperatorFilter.retrait,
              ),
            ),
            ChoiceChip(
              label: const Text('Transfert'),
              selected: _weeklyOperatorFilter == WeeklyOperatorFilter.transfert,
              onSelected: (_) => setState(
                () => _weeklyOperatorFilter = WeeklyOperatorFilter.transfert,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, int>>(
            stream: _weeklyOperatorStreamForFilter(),
            initialData: const <String, int>{},
            builder: (context, snapshot) {
              final data = snapshot.data!;
              if (data.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 64, color: Colors.grey),
                      Text(
                        'Aucun opérateur',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              final sorted = data.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final maxValue = sorted.first.value + 1;
              final bars = sorted
                  .asMap()
                  .entries
                  .map(
                    (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: _getOperatorColor(entry.value.key),
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  )
                  .toList();

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: maxValue.toDouble(),
                  barGroups: bars,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            sorted[value.toInt()].key,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        reservedSize: 32,
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

  Widget _buildTypesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Types',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        StreamBuilder<Map<String, int>>(
          stream: _database.countTransactionsByTypeWeek(),
          initialData: {'Retrait': 0, 'Dépot': 0, 'Transfert': 0},
          builder: (context, snapshot) {
            final data = snapshot.data!;
            return Row(
              children: [
                _buildTypeCard('Retrait', data['Retrait'] ?? 0, Colors.red),
                _buildTypeCard('Dépot', data['Dépot'] ?? 0, Colors.green),
                _buildTypeCard(
                  'Transfert',
                  data['Transfert'] ?? 0,
                  Colors.blue,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTypeCard(String type, int count, Color color) => Expanded(
    child: Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$count', style: TextStyle(fontSize: 24, color: color)),
          ],
        ),
      ),
    ),
  );

  Color _getOperatorColor(String operator) {
    final colors = {
      'orange': Colors.orange,
      'moov': Colors.green,
      'wave': Colors.blue,
      'telecel': Colors.purple,
      'sank': Colors.teal,
      'coris': Colors.red,
    };
    return colors[operator.toLowerCase()] ?? kPrimaryColor;
  }
}



