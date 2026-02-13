import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:aube/database/database.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({Key? key}) : super(key: key);

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  final AppDatabase db = AppDatabase();

  // --- Filtres ---
  List<String> selectedOperators = [
    'Orange',
    'Moov',
    'Telecel',
    'Sank',
    'Coris',
  ];
  String selectedPeriod = 'Ce mois';
  DateTimeRange? customDateRange;

  // Soft Premium Blue Palette
  static const Color bluePrimary = Color(0xFF81A4CD);
  static const Color blueSecondary = Color(0xFF3A4F7A);
  static const Color bgLight = Color(0xFFF7FAFF);
  static const Color white = Colors.white;
  static const Color textMain = Color(0xFF2D3142);
  static const Color purpleRoyal = Color(0xFF6200EE);
  static const Color purpleElectric = Color(0xFFA855F7);

  // Couleurs pour les opérateurs
  static const Map<String, Color> operatorColors = {
    'Orange': Color(0xFFFF6B35),
    'Moov': Color(0xFF4ECDC4),
    'Telecel': Color(0xFFF7B731),
    'Sank': Color(0xFF5F27CD),
    'Coris': Color(0xFF00D2D3),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: StreamBuilder<List<CoinsTableData>>(
          stream: db.select(db.coinsTable).watch(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: purpleRoyal),
              );
            }

            final allTx = snapshot.data!;
            final filteredTx = _applyFilters(allTx);
            final stats = _calculateKPIs(filteredTx);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickFilters(),
                  const SizedBox(height: 30),
                  _buildKPIGrid(stats),
                  const SizedBox(height: 30),
                  _buildDynamicBarChartCard(filteredTx),
                  const SizedBox(height: 30),
                  _buildOperatorBreakdown(filteredTx),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Statistiques",
          style: TextStyle(
            color: textMain,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(
            Iconsax.calendar_edit,
            color: blueSecondary,
            size: 24,
          ),
          onPressed: _showDateRangePicker,
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["Aujourd'hui", "Semaine", "Ce mois", "Custom"].map((p) {
          final isSelected = selectedPeriod == p;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedPeriod = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? purpleRoyal : white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  p,
                  style: TextStyle(
                    color: isSelected ? white : textMain.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPIGrid(Map<String, dynamic> current) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          "Total Flux",
          "${NumberFormat("#,###").format(current['totalAmount'])} F",
          Iconsax.wallet_3,
        ),
        _buildStatCard(
          "Transactions",
          "${current['count']}",
          Iconsax.receipt_item,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: blueSecondary, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textMain,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: textMain.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Graphique dynamique amélioré avec auto-ajustement
  Widget _buildDynamicBarChartCard(List<CoinsTableData> transactions) {
    final operatorData = _getOperatorDetailData(transactions);
    final chartData = _prepareChartData(operatorData);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Flux par Opérateur",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textMain,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: purpleRoyal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedPeriod,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: purpleRoyal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.chart,
                          size: 48,
                          color: textMain.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Aucune donnée disponible",
                          style: TextStyle(
                            color: textMain.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildDynamicBarChart(chartData),
          ),
          const SizedBox(height: 20),
          _buildLegend(operatorData),
        ],
      ),
    );
  }

  // Préparation des données avec filtrage des valeurs nulles
  List<ChartDataPoint> _prepareChartData(Map<String, double> operatorData) {
    List<ChartDataPoint> chartData = [];

    for (int i = 0; i < selectedOperators.length; i++) {
      final operator = selectedOperators[i];
      final amount = operatorData[operator] ?? 0;

      // On garde toutes les valeurs, même à 0, pour une meilleure cohérence visuelle
      chartData.add(
        ChartDataPoint(
          index: i,
          operator: operator,
          amount: amount,
          color: operatorColors[operator] ?? purpleRoyal,
        ),
      );
    }

    return chartData;
  }

  // Construction du graphique dynamique avec échelle intelligente
  Widget _buildDynamicBarChart(List<ChartDataPoint> chartData) {
    // Calcul de l'échelle optimale
    final amounts = chartData.map((d) => d.amount).toList();
    final maxAmount = amounts.isEmpty
        ? 0.0
        : amounts.reduce((a, b) => a > b ? a : b);
    final minAmount = amounts.isEmpty
        ? 0.0
        : amounts.reduce((a, b) => a < b ? a : b);

    // Auto-ajustement intelligent de l'échelle
    double chartMaxY;
    double chartMinY = 0; // Toujours partir de 0 pour éviter les distorsions

    if (maxAmount == 0) {
      chartMaxY = 100000; // Valeur par défaut
    } else {
      // Ajouter 20% d'espace au-dessus pour les étiquettes
      chartMaxY = maxAmount * 1.25;

      // Arrondir à un nombre "propre" pour une meilleure lisibilité
      chartMaxY = _roundToNiceNumber(chartMaxY);
    }

    return Stack(
      children: [
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: chartMaxY,
            minY: chartMinY,
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    _formatCurrency(rod.toY),
                    TextStyle(
                      color: rod.color ?? textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),

            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= chartData.length) {
                      return const SizedBox.shrink();
                    }
                    final operator = chartData[index].operator;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        operator,
                        style: TextStyle(
                          color: textMain.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: chartMaxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: textMain.withOpacity(0.05),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: chartData.map((data) {
              return BarChartGroupData(
                x: data.index,
                barRods: [
                  BarChartRodData(
                    toY: data.amount > 0
                        ? data.amount
                        : 0.1, // Minimum visible pour les valeurs à 0
                    color: data.amount > 0
                        ? data.color
                        : data.color.withOpacity(0.1),
                    width: 40,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    gradient: data.amount > 0
                        ? LinearGradient(
                            colors: [data.color, data.color.withOpacity(0.7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        // Overlay des valeurs numériques au-dessus des barres
      ],
    );
  }

  // Arrondir à un nombre "propre" pour l'échelle
  double _roundToNiceNumber(double value) {
    if (value <= 0) return 100000;

    final magnitude = (value.abs().toString().length - 1);
    final power = math.pow(10, magnitude).toDouble();
    final normalized = value / power;

    double nice;
    if (normalized < 1.5) {
      nice = 1.5;
    } else if (normalized < 2) {
      nice = 2;
    } else if (normalized < 2.5) {
      nice = 2.5;
    } else if (normalized < 5) {
      nice = 5;
    } else {
      nice = 10;
    }

    return nice * power;
  }

  // Format de devise intelligent avec plusieurs niveaux
  String _formatCurrency(double value) {
    if (value == 0) return '0 F';

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}Md F';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M F';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K F';
    } else {
      return '${value.toStringAsFixed(0)} F';
    }
  }

  Widget _buildLegend(Map<String, double> operatorData) {
    final totalAmount = operatorData.values.fold(0.0, (sum, val) => sum + val);

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: operatorData.entries.map((entry) {
        final color = operatorColors[entry.key] ?? purpleRoyal;
        final percentage = totalAmount > 0
            ? (entry.value / totalAmount * 100)
            : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key} ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textMain.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOperatorBreakdown(List<CoinsTableData> filteredTx) {
    final breakdown = _getOperatorDetailData(filteredTx);
    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Détails par Opérateur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textMain,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedBreakdown.map((entry) {
          final color = operatorColors[entry.key] ?? purpleRoyal;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _getOperatorIcon(entry.key, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textMain,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getTransactionCount(filteredTx, entry.key)} transaction(s)',
                        style: TextStyle(
                          fontSize: 11,
                          color: textMain.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${NumberFormat("#,###").format(entry.value)} F",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  int _getTransactionCount(List<CoinsTableData> tx, String operator) {
    return tx
        .where(
          (t) => t.operateur.toLowerCase().contains(operator.toLowerCase()),
        )
        .length;
  }

  List<CoinsTableData> _applyFilters(List<CoinsTableData> all) {
    DateTime now = DateTime.now();
    DateTime start;
    switch (selectedPeriod) {
      case 'Aujourd\'hui':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Semaine':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Ce mois':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Custom':
        if (customDateRange != null) {
          return all
              .where(
                (t) =>
                    t.dateDeTransaction.isAfter(customDateRange!.start) &&
                    t.dateDeTransaction.isBefore(
                      customDateRange!.end.add(const Duration(days: 1)),
                    ),
              )
              .toList();
        }
        start = DateTime(now.year, now.month, 1);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }
    return all.where((t) => t.dateDeTransaction.isAfter(start)).toList();
  }

  Map<String, dynamic> _calculateKPIs(List<CoinsTableData> tx) {
    final total = tx.fold(0.0, (sum, t) => sum + t.montant);
    return {'totalAmount': total, 'count': tx.length};
  }

  Map<String, double> _getOperatorDetailData(List<CoinsTableData> tx) {
    Map<String, double> map = {};
    for (var op in selectedOperators) {
      map[op] = tx
          .where((t) => t.operateur.toLowerCase().contains(op.toLowerCase()))
          .fold(0.0, (sum, t) => sum + t.montant);
    }
    return map;
  }

  Widget _getOperatorIcon(String op, {double size = 28}) {
    final lower = op.toLowerCase();
    String path = "assets/images/orange.png";
    if (lower.contains('orange')) path = "assets/images/orange.png";
    if (lower.contains('moov')) path = "assets/images/moov_africa.png";
    if (lower.contains('telecel')) path = "assets/images/telecel.png";
    if (lower.contains('sank')) path = "assets/images/sank.png";
    if (lower.contains('coris')) path = "assets/images/coris.png";
    return Image.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (c, e, s) =>
          Icon(Icons.wallet, color: bluePrimary, size: size),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: bluePrimary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedPeriod = 'Custom';
        customDateRange = picked;
      });
    }
  }
}

// Classe pour structurer les données du graphique
class ChartDataPoint {
  final int index;
  final String operator;
  final double amount;
  final Color color;

  ChartDataPoint({
    required this.index,
    required this.operator,
    required this.amount,
    required this.color,
  });
}



