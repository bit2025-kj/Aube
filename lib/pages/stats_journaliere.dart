import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:aube/database/database.dart';

const Color kPrimaryColor = Color(0xFF3A4F7A);
const Color kWhite = Color(0xFFFFFFFF);

class DailyStatsPage extends StatefulWidget {
  const DailyStatsPage({Key? key}) : super(key: key);

  @override
  State<DailyStatsPage> createState() => _DailyStatsPageState();
}

enum OperatorFilterType { all, depot, retrait, transfert }

enum HourFilterType { all, depot, retrait, transfert }

class _DailyStatsPageState extends State<DailyStatsPage> {
  final AppDatabase _database = AppDatabase();
  HourFilterType _hourFilter = HourFilterType.all;
  OperatorFilterType _operatorFilter = OperatorFilterType.all;

  String formatSolde(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }

  @override
  void initState() {
    super.initState();
    _database.debugTodayData(); // Debug JOURNÉE uniquement
  }

  Color _getOperatorColor(String op) {
    final colors = {
      'orange': Colors.orange,
      'moov': Colors.green,
      'wave': Colors.blue,
      'sank': Colors.teal,
      'telecel': Colors.purple,
      'coris': Colors.red,
    };
    return colors[op.toLowerCase()] ?? Colors.grey;
  }

  Color _getTypeColor(String type) {
    return switch (type) {
      'Retrait' => Colors.red,
      'Dépot' => Colors.green,
      'Transfert' => Colors.blue,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aujourd\'hui',
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
            _buildHourlyChart(),
            const SizedBox(height: 24),
            _buildOperatorsChart(),
            const SizedBox(height: 24),
            _buildTypesChart(),
            const SizedBox(height: 24),
            _buildHourOperatorTypeChart(),
          ],
        ),
      ),
    );
  }

  // Ligne SOLDE + TOTAL JOUR (J = somme des H)
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
                  StreamBuilder<int>(
                    // J = Σ H(h)
                    stream: _database.countTotalTodayFromHours(),
                    builder: (context, snapshot) => Text(
                      '${snapshot.data ?? 0}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<Map<int, int>> _hourStreamForFilter() {
    switch (_hourFilter) {
      case HourFilterType.depot:
        return _database.countByHourTodayByType('Dépot');
      case HourFilterType.retrait:
        return _database.countByHourTodayByType('Retrait');
      case HourFilterType.transfert:
        return _database.countByHourTodayByType('Transfert');
      case HourFilterType.all:
        return _database.countByHourToday();
    }
  }

  // Graph H(h) sur 24h
  Widget _buildHourlyChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité par heure',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // 🔘 Boutons filtre
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ChoiceChip(
              label: const Text('Tous'),
              selected: _hourFilter == HourFilterType.all,
              onSelected: (_) =>
                  setState(() => _hourFilter = HourFilterType.all),
            ),
            ChoiceChip(
              label: const Text('Dépôt'),
              selected: _hourFilter == HourFilterType.depot,
              onSelected: (_) =>
                  setState(() => _hourFilter = HourFilterType.depot),
            ),
            ChoiceChip(
              label: const Text('Retrait'),
              selected: _hourFilter == HourFilterType.retrait,
              onSelected: (_) =>
                  setState(() => _hourFilter = HourFilterType.retrait),
            ),
            ChoiceChip(
              label: const Text('Transfert'),
              selected: _hourFilter == HourFilterType.transfert,
              onSelected: (_) =>
                  setState(() => _hourFilter = HourFilterType.transfert),
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
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<int, int>>(
            stream: _hourStreamForFilter(),
            builder: (context, snapshot) {
              final byHour = snapshot.data ?? {};

              if (byHour.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey),
                      Text(
                        'Aucune donnée horaire',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // 0 → 23
              final hours = List.generate(24, (h) => h);
              final maxValue = byHour.values.isNotEmpty
                  ? byHour.values.reduce((a, b) => a > b ? a : b) + 1
                  : 1;

              final bars = hours.map((h) {
                final value = (byHour[h] ?? 0).toDouble();
                return BarChartGroupData(
                  x: h,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: kPrimaryColor,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
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
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final hour = value.toInt(); // 0..23
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${hour}h', // 0h, 1h, 2h...
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
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

  Stream<Map<String, int>> _operatorStreamForFilterToday() {
    switch (_operatorFilter) {
      case OperatorFilterType.depot:
        return _database.countTransactionsByOperatorTodayForType('Dépot');
      case OperatorFilterType.retrait:
        return _database.countTransactionsByOperatorTodayForType('Retrait');
      case OperatorFilterType.transfert:
        return _database.countTransactionsByOperatorTodayForType('Transfert');
      case OperatorFilterType.all:
        return _database
            .countTransactionsByOperator(); // ta méthode journalière existante
    }
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

        // 🔘 Filtres : Tous / Dépôt / Retrait / Transfert
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ChoiceChip(
              label: const Text('Tous'),
              selected: _operatorFilter == OperatorFilterType.all,
              onSelected: (_) =>
                  setState(() => _operatorFilter = OperatorFilterType.all),
            ),
            ChoiceChip(
              label: const Text('Dépôt'),
              selected: _operatorFilter == OperatorFilterType.depot,
              onSelected: (_) =>
                  setState(() => _operatorFilter = OperatorFilterType.depot),
            ),
            ChoiceChip(
              label: const Text('Retrait'),
              selected: _operatorFilter == OperatorFilterType.retrait,
              onSelected: (_) =>
                  setState(() => _operatorFilter = OperatorFilterType.retrait),
            ),
            ChoiceChip(
              label: const Text('Transfert'),
              selected: _operatorFilter == OperatorFilterType.transfert,
              onSelected: (_) => setState(
                () => _operatorFilter = OperatorFilterType.transfert,
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
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, int>>(
            stream: _operatorStreamForFilterToday(),
            initialData: const <String, int>{},
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
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

              final bars = sorted.asMap().entries.map((entry) {
                final index = entry.key;
                final opData = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: opData.value.toDouble(),
                      color: _getOperatorColor(opData.key),
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList();

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: maxValue.toDouble(),
                  barGroups: bars,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final opName = sorted[value.toInt()].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              opName.length > 4
                                  ? '${opName.substring(0, 3)}...'
                                  : opName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
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
          stream: _database.countTransactionsByType(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? {};
            return Row(
              children: [
                _buildTypeCard('Retrait', data['Retrait'] ?? 0, Colors.red),
                _buildTypeCard('Dépôt', data['Dépot'] ?? 0, Colors.green),
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

  Widget _buildTypeCard(String type, int count, Color color) {
    return Expanded(
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
  }

  Widget _buildHourOperatorTypeChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détail Heure/Opérateur/Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: StreamBuilder<Map<String, Map<String, Map<String, int>>>>(
            stream: _database.countTransactionsByHourOperatorTypeToday(),
            initialData: const {},
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? {};
              if (data.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.analytics,
                  message: 'Aucune donnée détaillée',
                );
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final hourEntry = data.entries.elementAt(index);
                  final hour = hourEntry.key;
                  final operators = hourEntry.value;
                  final totalHour = operators.values
                      .expand((types) => types.values)
                      .fold(0, (sum, count) => sum + count);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hour,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$totalHour tx',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      children: operators.entries.map((opEntry) {
                        final operator = opEntry.key;
                        final types = opEntry.value;
                        final totalOp = types.values.fold(
                          0,
                          (sum, count) => sum + count,
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          color: Colors.grey[50],
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: _getOperatorColor(
                                        operator,
                                      ),
                                      child: Text(
                                        operator[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      operator,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$totalOp',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            children: types.entries.map((typeEntry) {
                              final type = typeEntry.key;
                              final count = typeEntry.value;
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: _getTypeColor(type),
                                ),
                                title: Text(type),
                                trailing: Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyStateWidget({Key? key, required this.icon, required this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}



