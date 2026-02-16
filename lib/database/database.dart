import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'coin_table.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'coins.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [CoinsTable])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createAllTables();
      }
      if (from == 2) {
        print("Migration de 2 vers 3 effectuée");
      }
      if (from < 4) {
        // Ajout de la colonne userId
        await migrator.addColumn(coinsTable, coinsTable.userId);
        print("Migration vers v4: ajout colonne userId");
      }
    },
  );

  // ==== HELPERS TEMPS ====
  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _todayEnd() => _todayStart().add(const Duration(days: 1));

  // Début de semaine (lundi)
  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // ==== COMPTE TOTAL JOURNALIER ====
  Stream<int> countTotalTransactions(String userId) {
    final start = _todayStart();
    final end = _todayEnd();
    return select(coinsTable).watch().map((rows) {
      final todayCount = rows
          .where(
            (row) =>
                row.userId == userId &&
                row.dateDeTransaction.isAfter(
                  start.subtract(const Duration(seconds: 1)),
                ) &&
                row.dateDeTransaction.isBefore(end),
          )
          .length;
      return todayCount;
    });
  }

  // ==== NUCLEUS: COMPTE PAR HEURE SUR UN INTERVALLE ====
  Stream<Map<int, int>> countByHourInRange(DateTime start, DateTime end, String userId) {
    return (select(coinsTable)
          ..where((t) => t.dateDeTransaction.isBetweenValues(start, end) & t.userId.equals(userId)))
        .watch()
        .map((rows) {
          final map = <int, int>{};
          for (final row in rows) {
            final h = row.dateDeTransaction.hour;
            map[h] = (map[h] ?? 0) + 1;
          }
          return map;
        });
  }

  // ==== STATS JOURNALIÈRE PAR HEURE (H) ====
  Stream<Map<int, int>> countByHourToday(String userId) {
    final start = _todayStart();
    final end = _todayEnd();
    return countByHourInRange(start, end, userId);
  }

  // H(h) pour la journée, filtré par type
  Stream<Map<int, int>> countByHourTodayByType(String type, String userId) {
    final start = _todayStart();
    final end = _todayEnd();
    return (select(coinsTable)..where(
          (t) =>
              t.userId.equals(userId) &
              t.dateDeTransaction.isBetweenValues(start, end) &
              t.typeDeTransaction.equals(type),
        ))
        .watch()
        .map((rows) {
          final map = <int, int>{};
          for (final row in rows) {
            final h = row.dateDeTransaction.hour;
            map[h] = (map[h] ?? 0) + 1;
          }
          return map;
        });
  }

  // ==== STATS JOURNALIÈRE TOTALE (J = Σ H) ====
  Stream<int> countTotalTodayFromHours(String userId) {
    return countByHourToday(userId).map((byHour) {
      return byHour.values.fold(0, (sum, v) => sum + v);
    });
  }

  // ==== SOLDE TOTAL ====
  Stream<double> soldeTotalStream(String userId) => (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map(
    (coins) => coins.fold<double>(0.0, (sum, coin) {
      switch (coin.typeDeTransaction) {
        case 'Retrait':
          return sum + coin.montant;
        case 'Dépot':
        case 'Transfert':
          return sum - coin.montant;
        default:
          return sum;
      }
    }),
  );

  // ==== STATS JOURNALIÈRES PAR TYPE ====
  Stream<Map<String, int>> countTransactionsByType(String userId) {
    final start = _todayStart();
    final end = _todayEnd();
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final todayCoins = coins.where(
        (c) =>
            c.dateDeTransaction.isAfter(
              start.subtract(const Duration(seconds: 1)),
            ) &&
            c.dateDeTransaction.isBefore(end),
      );
      final map = <String, int>{};
      for (final coin in todayCoins) {
        map[coin.typeDeTransaction] = (map[coin.typeDeTransaction] ?? 0) + 1;
      }
      return map;
    });
  }

  // ==== STATS JOURNALIÈRES PAR OPÉRATEUR ====
  Stream<Map<String, int>> countTransactionsByOperator(String userId) {
    final start = _todayStart();
    final end = _todayEnd();
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final todayCoins = coins.where(
        (c) =>
            c.dateDeTransaction.isAfter(
              start.subtract(const Duration(seconds: 1)),
            ) &&
            c.dateDeTransaction.isBefore(end),
      );
      final map = <String, int>{};
      for (final coin in todayCoins) {
        map[coin.operateur] = (map[coin.operateur] ?? 0) + 1;
      }
      return map;
    });
  }

  // Opérateurs JOURNÉE filtrés par type
  Stream<Map<String, int>> countTransactionsByOperatorTodayForType(
    String type,
    String userId,
  ) {
    final start = _todayStart();
    final end = _todayEnd();
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final todayCoins = coins.where(
        (c) =>
            c.dateDeTransaction.isAfter(
              start.subtract(const Duration(seconds: 1)),
            ) &&
            c.dateDeTransaction.isBefore(end) &&
            c.typeDeTransaction == type,
      );
      final map = <String, int>{};
      for (final coin in todayCoins) {
        map[coin.operateur] = (map[coin.operateur] ?? 0) + 1;
      }
      return map;
    });
  }

  // ==== HEURE → OPÉRATEUR → TYPE (structure détaillée pour la journée) ====
  Stream<Map<String, Map<String, Map<String, int>>>>
  countTransactionsByHourOperatorTypeToday(String userId) {
    final start = _todayStart();
    final end = _todayEnd();

    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final todayCoins = coins.where(
        (c) =>
            c.dateDeTransaction.isAfter(
              start.subtract(const Duration(seconds: 1)),
            ) &&
            c.dateDeTransaction.isBefore(end),
      );

      final Map<String, Map<String, Map<String, int>>> data = {};

      for (final coin in todayCoins) {
        final hour =
            '${coin.dateDeTransaction.hour.toString().padLeft(2, '0')}:00';
        final operator = coin.operateur;
        final type = coin.typeDeTransaction;

        data.putIfAbsent(hour, () => {});
        data[hour]!.putIfAbsent(operator, () => {});
        data[hour]![operator]![type] = (data[hour]![operator]![type] ?? 0) + 1;
      }

      return data;
    });
  }

  // ==== STATS SEMAINE ====
  // Jours de la semaine
  Stream<Map<String, int>> countTransactionsByWeekDay(String userId, {String? typeFilter}) {
    final start = _startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final map = {for (var d in days) d: 0};
      for (final coin in coins) {
        final dt = coin.dateDeTransaction;
        if (dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(end)) {
          if (typeFilter == null || coin.typeDeTransaction == typeFilter) {
            final dayKey = days[dt.weekday - 1];
            map[dayKey] = (map[dayKey] ?? 0) + 1;
          }
        }
      }
      return map;
    });
  }

  // Opérateurs semaine
  Stream<Map<String, int>> countTransactionsByOperatorWeek(String userId) {
    final start = _startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final map = <String, int>{};
      for (final coin in coins) {
        final dt = coin.dateDeTransaction;
        if (dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(end)) {
          map[coin.operateur] = (map[coin.operateur] ?? 0) + 1;
        }
      }
      return map;
    });
  }

  // Opérateurs semaine filtrés par type (POUR LES FILTRES CHOICECHIP)
  Stream<Map<String, int>> countTransactionsByOperatorWeekForType(String type, String userId) {
    final start = _startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final map = <String, int>{};
      for (final coin in coins) {
        final dt = coin.dateDeTransaction;
        if (dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(end) &&
            coin.typeDeTransaction == type) {
          map[coin.operateur] = (map[coin.operateur] ?? 0) + 1;
        }
      }
      return map;
    });
  }

  // Types semaine
  Stream<Map<String, int>> countTransactionsByTypeWeek(String userId) {
    final start = _startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final map = <String, int>{};
      for (final coin in coins) {
        final dt = coin.dateDeTransaction;
        if (dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(end)) {
          map[coin.typeDeTransaction] = (map[coin.typeDeTransaction] ?? 0) + 1;
        }
      }
      return map;
    });
  } // ← Fermer proprement

  // ==== STATS ANNUELLES ====
  Stream<Map<String, int>> countTransactionsByYear(String userId) {
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final Map<String, int> yearsCount = {};
      for (final coin in coins) {
        final year = coin.dateDeTransaction.year.toString();
        yearsCount[year] = (yearsCount[year] ?? 0) + 1;
      }
      return yearsCount;
    });
  }

  // ==== STATS MENSUELLES ====
  Stream<Map<String, int>> countTransactionsByMonth(String userId) {
    return (select(coinsTable)..where((t) => t.userId.equals(userId))).watch().map((coins) {
      final Map<String, int> monthsCount = {};
      for (final coin in coins) {
        final monthKey =
            '${coin.dateDeTransaction.year}-${coin.dateDeTransaction.month.toString().padLeft(2, '0')}';
        monthsCount[monthKey] = (monthsCount[monthKey] ?? 0) + 1;
      }
      return monthsCount;
    });
  } // ← Fermer proprement

  // ==== DEBUG ====
  Future<void> debugTodayData() async {
    final start = _todayStart();
    final end = _todayEnd();
    final todayCoins = await (select(
      coinsTable,
    )..where((tbl) => tbl.dateDeTransaction.isBetweenValues(start, end))).get();
    print('📅 TRANSACTIONS AUJOURD\'HUI: ${todayCoins.length}');
    for (var coin in todayCoins) {
      print(
        '  📊 ${coin.operateur} - ${coin.typeDeTransaction} - ${coin.dateDeTransaction}',
      );
    }
  }

  Future<void> debugWeekData() async {
    final start = _startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    final weekCoins = await (select(
      coinsTable,
    )..where((tbl) => tbl.dateDeTransaction.isBetweenValues(start, end))).get();
    print(
      '📅 TRANSACTIONS SEMAINE (${start.toString().substring(0, 10)} → ${end.toString().substring(0, 10)}): ${weekCoins.length}',
    );
    for (var coin in weekCoins) {
      print(
        '  📊 ${coin.operateur} - ${coin.typeDeTransaction} - ${coin.dateDeTransaction}',
      );
    }
  }

  // ==== CRUD CLASSIQUE ====
  Future<int> insertCoin(CoinsTableCompanion coin) =>
      into(coinsTable).insert(coin);

  Future<List<CoinsTableData>> getAllCoins(String userId) => (select(coinsTable)..where((t) => t.userId.equals(userId))).get();

  Stream<List<CoinsTableData>> watchAllCoins(String userId) => (select(coinsTable)..where((t) => t.userId.equals(userId))).watch();

  Future<int> deleteCoin(int id, String userId) =>
      (delete(coinsTable)..where((t) => t.id.equals(id) & t.userId.equals(userId))).go();

  Future<void> updateCoin(CoinsTableData coin) async {
    await update(coinsTable).replace(coin);
  }
}



