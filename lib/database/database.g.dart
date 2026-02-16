// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CoinsTableTable extends CoinsTable
    with TableInfo<$CoinsTableTable, CoinsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoinsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prenomMeta = const VerificationMeta('prenom');
  @override
  late final GeneratedColumn<String> prenom = GeneratedColumn<String>(
      'prenom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeDePieceMeta =
      const VerificationMeta('typeDePiece');
  @override
  late final GeneratedColumn<String> typeDePiece = GeneratedColumn<String>(
      'type_de_piece', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numeroDePieceMeta =
      const VerificationMeta('numeroDePiece');
  @override
  late final GeneratedColumn<String> numeroDePiece = GeneratedColumn<String>(
      'numero_de_piece', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateDePeremptionMeta =
      const VerificationMeta('dateDePeremption');
  @override
  late final GeneratedColumn<DateTime> dateDePeremption =
      GeneratedColumn<DateTime>('date_de_peremption', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _typeDeTransactionMeta =
      const VerificationMeta('typeDeTransaction');
  @override
  late final GeneratedColumn<String> typeDeTransaction =
      GeneratedColumn<String>('type_de_transaction', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _montantMeta =
      const VerificationMeta('montant');
  @override
  late final GeneratedColumn<double> montant = GeneratedColumn<double>(
      'montant', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _operateurMeta =
      const VerificationMeta('operateur');
  @override
  late final GeneratedColumn<String> operateur = GeneratedColumn<String>(
      'operateur', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numeroDeTelephoneMeta =
      const VerificationMeta('numeroDeTelephone');
  @override
  late final GeneratedColumn<String> numeroDeTelephone =
      GeneratedColumn<String>('numero_de_telephone', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateDeTransactionMeta =
      const VerificationMeta('dateDeTransaction');
  @override
  late final GeneratedColumn<DateTime> dateDeTransaction =
      GeneratedColumn<DateTime>('date_de_transaction', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nom,
        prenom,
        typeDePiece,
        numeroDePiece,
        dateDePeremption,
        typeDeTransaction,
        montant,
        operateur,
        numeroDeTelephone,
        dateDeTransaction,
        userId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coins_table';
  @override
  VerificationContext validateIntegrity(Insertable<CoinsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('prenom')) {
      context.handle(_prenomMeta,
          prenom.isAcceptableOrUnknown(data['prenom']!, _prenomMeta));
    } else if (isInserting) {
      context.missing(_prenomMeta);
    }
    if (data.containsKey('type_de_piece')) {
      context.handle(
          _typeDePieceMeta,
          typeDePiece.isAcceptableOrUnknown(
              data['type_de_piece']!, _typeDePieceMeta));
    } else if (isInserting) {
      context.missing(_typeDePieceMeta);
    }
    if (data.containsKey('numero_de_piece')) {
      context.handle(
          _numeroDePieceMeta,
          numeroDePiece.isAcceptableOrUnknown(
              data['numero_de_piece']!, _numeroDePieceMeta));
    } else if (isInserting) {
      context.missing(_numeroDePieceMeta);
    }
    if (data.containsKey('date_de_peremption')) {
      context.handle(
          _dateDePeremptionMeta,
          dateDePeremption.isAcceptableOrUnknown(
              data['date_de_peremption']!, _dateDePeremptionMeta));
    } else if (isInserting) {
      context.missing(_dateDePeremptionMeta);
    }
    if (data.containsKey('type_de_transaction')) {
      context.handle(
          _typeDeTransactionMeta,
          typeDeTransaction.isAcceptableOrUnknown(
              data['type_de_transaction']!, _typeDeTransactionMeta));
    } else if (isInserting) {
      context.missing(_typeDeTransactionMeta);
    }
    if (data.containsKey('montant')) {
      context.handle(_montantMeta,
          montant.isAcceptableOrUnknown(data['montant']!, _montantMeta));
    } else if (isInserting) {
      context.missing(_montantMeta);
    }
    if (data.containsKey('operateur')) {
      context.handle(_operateurMeta,
          operateur.isAcceptableOrUnknown(data['operateur']!, _operateurMeta));
    } else if (isInserting) {
      context.missing(_operateurMeta);
    }
    if (data.containsKey('numero_de_telephone')) {
      context.handle(
          _numeroDeTelephoneMeta,
          numeroDeTelephone.isAcceptableOrUnknown(
              data['numero_de_telephone']!, _numeroDeTelephoneMeta));
    } else if (isInserting) {
      context.missing(_numeroDeTelephoneMeta);
    }
    if (data.containsKey('date_de_transaction')) {
      context.handle(
          _dateDeTransactionMeta,
          dateDeTransaction.isAcceptableOrUnknown(
              data['date_de_transaction']!, _dateDeTransactionMeta));
    } else if (isInserting) {
      context.missing(_dateDeTransactionMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoinsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoinsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      prenom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prenom'])!,
      typeDePiece: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_de_piece'])!,
      numeroDePiece: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}numero_de_piece'])!,
      dateDePeremption: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_de_peremption'])!,
      typeDeTransaction: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}type_de_transaction'])!,
      montant: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}montant'])!,
      operateur: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operateur'])!,
      numeroDeTelephone: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}numero_de_telephone'])!,
      dateDeTransaction: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}date_de_transaction'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
    );
  }

  @override
  $CoinsTableTable createAlias(String alias) {
    return $CoinsTableTable(attachedDatabase, alias);
  }
}

class CoinsTableData extends DataClass implements Insertable<CoinsTableData> {
  final int id;
  final String nom;
  final String prenom;
  final String typeDePiece;
  final String numeroDePiece;
  final DateTime dateDePeremption;
  final String typeDeTransaction;
  final double montant;
  final String operateur;
  final String numeroDeTelephone;
  final DateTime dateDeTransaction;
  final String userId;
  const CoinsTableData(
      {required this.id,
      required this.nom,
      required this.prenom,
      required this.typeDePiece,
      required this.numeroDePiece,
      required this.dateDePeremption,
      required this.typeDeTransaction,
      required this.montant,
      required this.operateur,
      required this.numeroDeTelephone,
      required this.dateDeTransaction,
      required this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['prenom'] = Variable<String>(prenom);
    map['type_de_piece'] = Variable<String>(typeDePiece);
    map['numero_de_piece'] = Variable<String>(numeroDePiece);
    map['date_de_peremption'] = Variable<DateTime>(dateDePeremption);
    map['type_de_transaction'] = Variable<String>(typeDeTransaction);
    map['montant'] = Variable<double>(montant);
    map['operateur'] = Variable<String>(operateur);
    map['numero_de_telephone'] = Variable<String>(numeroDeTelephone);
    map['date_de_transaction'] = Variable<DateTime>(dateDeTransaction);
    map['user_id'] = Variable<String>(userId);
    return map;
  }

  CoinsTableCompanion toCompanion(bool nullToAbsent) {
    return CoinsTableCompanion(
      id: Value(id),
      nom: Value(nom),
      prenom: Value(prenom),
      typeDePiece: Value(typeDePiece),
      numeroDePiece: Value(numeroDePiece),
      dateDePeremption: Value(dateDePeremption),
      typeDeTransaction: Value(typeDeTransaction),
      montant: Value(montant),
      operateur: Value(operateur),
      numeroDeTelephone: Value(numeroDeTelephone),
      dateDeTransaction: Value(dateDeTransaction),
      userId: Value(userId),
    );
  }

  factory CoinsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoinsTableData(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      prenom: serializer.fromJson<String>(json['prenom']),
      typeDePiece: serializer.fromJson<String>(json['typeDePiece']),
      numeroDePiece: serializer.fromJson<String>(json['numeroDePiece']),
      dateDePeremption: serializer.fromJson<DateTime>(json['dateDePeremption']),
      typeDeTransaction: serializer.fromJson<String>(json['typeDeTransaction']),
      montant: serializer.fromJson<double>(json['montant']),
      operateur: serializer.fromJson<String>(json['operateur']),
      numeroDeTelephone: serializer.fromJson<String>(json['numeroDeTelephone']),
      dateDeTransaction:
          serializer.fromJson<DateTime>(json['dateDeTransaction']),
      userId: serializer.fromJson<String>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'prenom': serializer.toJson<String>(prenom),
      'typeDePiece': serializer.toJson<String>(typeDePiece),
      'numeroDePiece': serializer.toJson<String>(numeroDePiece),
      'dateDePeremption': serializer.toJson<DateTime>(dateDePeremption),
      'typeDeTransaction': serializer.toJson<String>(typeDeTransaction),
      'montant': serializer.toJson<double>(montant),
      'operateur': serializer.toJson<String>(operateur),
      'numeroDeTelephone': serializer.toJson<String>(numeroDeTelephone),
      'dateDeTransaction': serializer.toJson<DateTime>(dateDeTransaction),
      'userId': serializer.toJson<String>(userId),
    };
  }

  CoinsTableData copyWith(
          {int? id,
          String? nom,
          String? prenom,
          String? typeDePiece,
          String? numeroDePiece,
          DateTime? dateDePeremption,
          String? typeDeTransaction,
          double? montant,
          String? operateur,
          String? numeroDeTelephone,
          DateTime? dateDeTransaction,
          String? userId}) =>
      CoinsTableData(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        prenom: prenom ?? this.prenom,
        typeDePiece: typeDePiece ?? this.typeDePiece,
        numeroDePiece: numeroDePiece ?? this.numeroDePiece,
        dateDePeremption: dateDePeremption ?? this.dateDePeremption,
        typeDeTransaction: typeDeTransaction ?? this.typeDeTransaction,
        montant: montant ?? this.montant,
        operateur: operateur ?? this.operateur,
        numeroDeTelephone: numeroDeTelephone ?? this.numeroDeTelephone,
        dateDeTransaction: dateDeTransaction ?? this.dateDeTransaction,
        userId: userId ?? this.userId,
      );
  CoinsTableData copyWithCompanion(CoinsTableCompanion data) {
    return CoinsTableData(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      prenom: data.prenom.present ? data.prenom.value : this.prenom,
      typeDePiece:
          data.typeDePiece.present ? data.typeDePiece.value : this.typeDePiece,
      numeroDePiece: data.numeroDePiece.present
          ? data.numeroDePiece.value
          : this.numeroDePiece,
      dateDePeremption: data.dateDePeremption.present
          ? data.dateDePeremption.value
          : this.dateDePeremption,
      typeDeTransaction: data.typeDeTransaction.present
          ? data.typeDeTransaction.value
          : this.typeDeTransaction,
      montant: data.montant.present ? data.montant.value : this.montant,
      operateur: data.operateur.present ? data.operateur.value : this.operateur,
      numeroDeTelephone: data.numeroDeTelephone.present
          ? data.numeroDeTelephone.value
          : this.numeroDeTelephone,
      dateDeTransaction: data.dateDeTransaction.present
          ? data.dateDeTransaction.value
          : this.dateDeTransaction,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoinsTableData(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('typeDePiece: $typeDePiece, ')
          ..write('numeroDePiece: $numeroDePiece, ')
          ..write('dateDePeremption: $dateDePeremption, ')
          ..write('typeDeTransaction: $typeDeTransaction, ')
          ..write('montant: $montant, ')
          ..write('operateur: $operateur, ')
          ..write('numeroDeTelephone: $numeroDeTelephone, ')
          ..write('dateDeTransaction: $dateDeTransaction, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nom,
      prenom,
      typeDePiece,
      numeroDePiece,
      dateDePeremption,
      typeDeTransaction,
      montant,
      operateur,
      numeroDeTelephone,
      dateDeTransaction,
      userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoinsTableData &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.prenom == this.prenom &&
          other.typeDePiece == this.typeDePiece &&
          other.numeroDePiece == this.numeroDePiece &&
          other.dateDePeremption == this.dateDePeremption &&
          other.typeDeTransaction == this.typeDeTransaction &&
          other.montant == this.montant &&
          other.operateur == this.operateur &&
          other.numeroDeTelephone == this.numeroDeTelephone &&
          other.dateDeTransaction == this.dateDeTransaction &&
          other.userId == this.userId);
}

class CoinsTableCompanion extends UpdateCompanion<CoinsTableData> {
  final Value<int> id;
  final Value<String> nom;
  final Value<String> prenom;
  final Value<String> typeDePiece;
  final Value<String> numeroDePiece;
  final Value<DateTime> dateDePeremption;
  final Value<String> typeDeTransaction;
  final Value<double> montant;
  final Value<String> operateur;
  final Value<String> numeroDeTelephone;
  final Value<DateTime> dateDeTransaction;
  final Value<String> userId;
  const CoinsTableCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.prenom = const Value.absent(),
    this.typeDePiece = const Value.absent(),
    this.numeroDePiece = const Value.absent(),
    this.dateDePeremption = const Value.absent(),
    this.typeDeTransaction = const Value.absent(),
    this.montant = const Value.absent(),
    this.operateur = const Value.absent(),
    this.numeroDeTelephone = const Value.absent(),
    this.dateDeTransaction = const Value.absent(),
    this.userId = const Value.absent(),
  });
  CoinsTableCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    required String prenom,
    required String typeDePiece,
    required String numeroDePiece,
    required DateTime dateDePeremption,
    required String typeDeTransaction,
    required double montant,
    required String operateur,
    required String numeroDeTelephone,
    required DateTime dateDeTransaction,
    required String userId,
  })  : nom = Value(nom),
        prenom = Value(prenom),
        typeDePiece = Value(typeDePiece),
        numeroDePiece = Value(numeroDePiece),
        dateDePeremption = Value(dateDePeremption),
        typeDeTransaction = Value(typeDeTransaction),
        montant = Value(montant),
        operateur = Value(operateur),
        numeroDeTelephone = Value(numeroDeTelephone),
        dateDeTransaction = Value(dateDeTransaction),
        userId = Value(userId);
  static Insertable<CoinsTableData> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? prenom,
    Expression<String>? typeDePiece,
    Expression<String>? numeroDePiece,
    Expression<DateTime>? dateDePeremption,
    Expression<String>? typeDeTransaction,
    Expression<double>? montant,
    Expression<String>? operateur,
    Expression<String>? numeroDeTelephone,
    Expression<DateTime>? dateDeTransaction,
    Expression<String>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (typeDePiece != null) 'type_de_piece': typeDePiece,
      if (numeroDePiece != null) 'numero_de_piece': numeroDePiece,
      if (dateDePeremption != null) 'date_de_peremption': dateDePeremption,
      if (typeDeTransaction != null) 'type_de_transaction': typeDeTransaction,
      if (montant != null) 'montant': montant,
      if (operateur != null) 'operateur': operateur,
      if (numeroDeTelephone != null) 'numero_de_telephone': numeroDeTelephone,
      if (dateDeTransaction != null) 'date_de_transaction': dateDeTransaction,
      if (userId != null) 'user_id': userId,
    });
  }

  CoinsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? nom,
      Value<String>? prenom,
      Value<String>? typeDePiece,
      Value<String>? numeroDePiece,
      Value<DateTime>? dateDePeremption,
      Value<String>? typeDeTransaction,
      Value<double>? montant,
      Value<String>? operateur,
      Value<String>? numeroDeTelephone,
      Value<DateTime>? dateDeTransaction,
      Value<String>? userId}) {
    return CoinsTableCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      typeDePiece: typeDePiece ?? this.typeDePiece,
      numeroDePiece: numeroDePiece ?? this.numeroDePiece,
      dateDePeremption: dateDePeremption ?? this.dateDePeremption,
      typeDeTransaction: typeDeTransaction ?? this.typeDeTransaction,
      montant: montant ?? this.montant,
      operateur: operateur ?? this.operateur,
      numeroDeTelephone: numeroDeTelephone ?? this.numeroDeTelephone,
      dateDeTransaction: dateDeTransaction ?? this.dateDeTransaction,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (prenom.present) {
      map['prenom'] = Variable<String>(prenom.value);
    }
    if (typeDePiece.present) {
      map['type_de_piece'] = Variable<String>(typeDePiece.value);
    }
    if (numeroDePiece.present) {
      map['numero_de_piece'] = Variable<String>(numeroDePiece.value);
    }
    if (dateDePeremption.present) {
      map['date_de_peremption'] = Variable<DateTime>(dateDePeremption.value);
    }
    if (typeDeTransaction.present) {
      map['type_de_transaction'] = Variable<String>(typeDeTransaction.value);
    }
    if (montant.present) {
      map['montant'] = Variable<double>(montant.value);
    }
    if (operateur.present) {
      map['operateur'] = Variable<String>(operateur.value);
    }
    if (numeroDeTelephone.present) {
      map['numero_de_telephone'] = Variable<String>(numeroDeTelephone.value);
    }
    if (dateDeTransaction.present) {
      map['date_de_transaction'] = Variable<DateTime>(dateDeTransaction.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoinsTableCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('prenom: $prenom, ')
          ..write('typeDePiece: $typeDePiece, ')
          ..write('numeroDePiece: $numeroDePiece, ')
          ..write('dateDePeremption: $dateDePeremption, ')
          ..write('typeDeTransaction: $typeDeTransaction, ')
          ..write('montant: $montant, ')
          ..write('operateur: $operateur, ')
          ..write('numeroDeTelephone: $numeroDeTelephone, ')
          ..write('dateDeTransaction: $dateDeTransaction, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoinsTableTable coinsTable = $CoinsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [coinsTable];
}

typedef $$CoinsTableTableCreateCompanionBuilder = CoinsTableCompanion Function({
  Value<int> id,
  required String nom,
  required String prenom,
  required String typeDePiece,
  required String numeroDePiece,
  required DateTime dateDePeremption,
  required String typeDeTransaction,
  required double montant,
  required String operateur,
  required String numeroDeTelephone,
  required DateTime dateDeTransaction,
  required String userId,
});
typedef $$CoinsTableTableUpdateCompanionBuilder = CoinsTableCompanion Function({
  Value<int> id,
  Value<String> nom,
  Value<String> prenom,
  Value<String> typeDePiece,
  Value<String> numeroDePiece,
  Value<DateTime> dateDePeremption,
  Value<String> typeDeTransaction,
  Value<double> montant,
  Value<String> operateur,
  Value<String> numeroDeTelephone,
  Value<DateTime> dateDeTransaction,
  Value<String> userId,
});

class $$CoinsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CoinsTableTable> {
  $$CoinsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prenom => $composableBuilder(
      column: $table.prenom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeDePiece => $composableBuilder(
      column: $table.typeDePiece, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroDePiece => $composableBuilder(
      column: $table.numeroDePiece, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateDePeremption => $composableBuilder(
      column: $table.dateDePeremption,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeDeTransaction => $composableBuilder(
      column: $table.typeDeTransaction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operateur => $composableBuilder(
      column: $table.operateur, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroDeTelephone => $composableBuilder(
      column: $table.numeroDeTelephone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateDeTransaction => $composableBuilder(
      column: $table.dateDeTransaction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));
}

class $$CoinsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CoinsTableTable> {
  $$CoinsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prenom => $composableBuilder(
      column: $table.prenom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeDePiece => $composableBuilder(
      column: $table.typeDePiece, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroDePiece => $composableBuilder(
      column: $table.numeroDePiece,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateDePeremption => $composableBuilder(
      column: $table.dateDePeremption,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeDeTransaction => $composableBuilder(
      column: $table.typeDeTransaction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operateur => $composableBuilder(
      column: $table.operateur, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroDeTelephone => $composableBuilder(
      column: $table.numeroDeTelephone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateDeTransaction => $composableBuilder(
      column: $table.dateDeTransaction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));
}

class $$CoinsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoinsTableTable> {
  $$CoinsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get prenom =>
      $composableBuilder(column: $table.prenom, builder: (column) => column);

  GeneratedColumn<String> get typeDePiece => $composableBuilder(
      column: $table.typeDePiece, builder: (column) => column);

  GeneratedColumn<String> get numeroDePiece => $composableBuilder(
      column: $table.numeroDePiece, builder: (column) => column);

  GeneratedColumn<DateTime> get dateDePeremption => $composableBuilder(
      column: $table.dateDePeremption, builder: (column) => column);

  GeneratedColumn<String> get typeDeTransaction => $composableBuilder(
      column: $table.typeDeTransaction, builder: (column) => column);

  GeneratedColumn<double> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumn<String> get operateur =>
      $composableBuilder(column: $table.operateur, builder: (column) => column);

  GeneratedColumn<String> get numeroDeTelephone => $composableBuilder(
      column: $table.numeroDeTelephone, builder: (column) => column);

  GeneratedColumn<DateTime> get dateDeTransaction => $composableBuilder(
      column: $table.dateDeTransaction, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$CoinsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CoinsTableTable,
    CoinsTableData,
    $$CoinsTableTableFilterComposer,
    $$CoinsTableTableOrderingComposer,
    $$CoinsTableTableAnnotationComposer,
    $$CoinsTableTableCreateCompanionBuilder,
    $$CoinsTableTableUpdateCompanionBuilder,
    (
      CoinsTableData,
      BaseReferences<_$AppDatabase, $CoinsTableTable, CoinsTableData>
    ),
    CoinsTableData,
    PrefetchHooks Function()> {
  $$CoinsTableTableTableManager(_$AppDatabase db, $CoinsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoinsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoinsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoinsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String> prenom = const Value.absent(),
            Value<String> typeDePiece = const Value.absent(),
            Value<String> numeroDePiece = const Value.absent(),
            Value<DateTime> dateDePeremption = const Value.absent(),
            Value<String> typeDeTransaction = const Value.absent(),
            Value<double> montant = const Value.absent(),
            Value<String> operateur = const Value.absent(),
            Value<String> numeroDeTelephone = const Value.absent(),
            Value<DateTime> dateDeTransaction = const Value.absent(),
            Value<String> userId = const Value.absent(),
          }) =>
              CoinsTableCompanion(
            id: id,
            nom: nom,
            prenom: prenom,
            typeDePiece: typeDePiece,
            numeroDePiece: numeroDePiece,
            dateDePeremption: dateDePeremption,
            typeDeTransaction: typeDeTransaction,
            montant: montant,
            operateur: operateur,
            numeroDeTelephone: numeroDeTelephone,
            dateDeTransaction: dateDeTransaction,
            userId: userId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nom,
            required String prenom,
            required String typeDePiece,
            required String numeroDePiece,
            required DateTime dateDePeremption,
            required String typeDeTransaction,
            required double montant,
            required String operateur,
            required String numeroDeTelephone,
            required DateTime dateDeTransaction,
            required String userId,
          }) =>
              CoinsTableCompanion.insert(
            id: id,
            nom: nom,
            prenom: prenom,
            typeDePiece: typeDePiece,
            numeroDePiece: numeroDePiece,
            dateDePeremption: dateDePeremption,
            typeDeTransaction: typeDeTransaction,
            montant: montant,
            operateur: operateur,
            numeroDeTelephone: numeroDeTelephone,
            dateDeTransaction: dateDeTransaction,
            userId: userId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CoinsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CoinsTableTable,
    CoinsTableData,
    $$CoinsTableTableFilterComposer,
    $$CoinsTableTableOrderingComposer,
    $$CoinsTableTableAnnotationComposer,
    $$CoinsTableTableCreateCompanionBuilder,
    $$CoinsTableTableUpdateCompanionBuilder,
    (
      CoinsTableData,
      BaseReferences<_$AppDatabase, $CoinsTableTable, CoinsTableData>
    ),
    CoinsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoinsTableTableTableManager get coinsTable =>
      $$CoinsTableTableTableManager(_db, _db.coinsTable);
}
