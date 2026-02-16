// lib/database/coin_table.dart

import 'package:drift/drift.dart';

class CoinsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text()();
  TextColumn get prenom => text()();
  TextColumn get typeDePiece => text()();
  TextColumn get numeroDePiece => text()();
  
  // CHANGEMENT : Passe à DateTime pour un meilleur traitement de la date
  DateTimeColumn get dateDePeremption => dateTime()(); 
  
  TextColumn get typeDeTransaction => text()();
  RealColumn get montant => real()();
  TextColumn get operateur => text()();
  TextColumn get numeroDeTelephone => text()();
  
  // CHANGEMENT MAJEUR : Passe à DateTime (pour inclure la date ET l'heure)
  DateTimeColumn get dateDeTransaction => dateTime()();
  
  // NOUVEAU : ID de l'utilisateur pour cloisonner les données
  TextColumn get userId => text()();
  
  // SUPPRIMÉ : Nous n'avons plus besoin d'une colonne séparée pour l'heure.
}


