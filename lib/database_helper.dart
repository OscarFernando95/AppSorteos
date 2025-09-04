// lib/database_helper.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> _getDbPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'sorteos.db');
    return path;
  }

  Future<Database> _initDatabase() async {
    final path = await _getDbPath();
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onOpen(Database db) async {
    // Habilitar foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sorteos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        fecha_hora TEXT NOT NULL,
        creado_en TEXT DEFAULT (datetime('now'))
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS numbers (
        sorteo_id INTEGER NOT NULL,
        num TEXT NOT NULL,
        estado TEXT NOT NULL,
        telefono TEXT,
        notificado INTEGER DEFAULT 0,
        notified_at TEXT,
        PRIMARY KEY (sorteo_id, num),
        FOREIGN KEY (sorteo_id) REFERENCES sorteos(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Si más adelante cambias esquema, maneja migraciones aquí.
  }

  // Path (útil para debugging)
  Future<String> getDatabasePath() async {
    return await _getDbPath();
  }

  // Crear un nuevo sorteo y poblar 00..99
  Future<int> createSorteo(String nombre, DateTime fechaHora) async {
    final db = await database;
    final id = await db.insert('sorteos', {
      'nombre': nombre,
      'fecha_hora': fechaHora.toIso8601String(),
    });

    final batch = db.batch();
    for (int i = 0; i < 100; i++) {
      final n = i.toString().padLeft(2, '0');
      batch.insert('numbers', {
        'sorteo_id': id,
        'num': n,
        'estado': 'Disponible',
        'telefono': null,
        'notificado': 0
      });
    }
    await batch.commit(noResult: true);
    return id;
  }

  // Obtener lista de sorteos
  Future<List<Map<String, dynamic>>> getSorteos() async {
    final db = await database;
    return await db.query('sorteos', orderBy: 'fecha_hora DESC');
  }

  // Obtener números de un sorteo
  Future<List<Map<String, dynamic>>> getNumbersForSorteo(int sorteoId) async {
    final db = await database;
    return await db.query('numbers', where: 'sorteo_id = ?', whereArgs: [sorteoId], orderBy: 'num');
  }

  // Update ejemplo (asignar telefono/estado)
  Future<int> updateNumber(int sorteoId, String num, Map<String, dynamic> values) async {
    final db = await database;
    return await db.update('numbers', values, where: 'sorteo_id = ? AND num = ?', whereArgs: [sorteoId, num]);
  }

  // Marcar notificado
  Future<void> markNotified(int sorteoId, List<String> nums) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final n in nums) {
      batch.update('numbers', {'notificado': 1, 'notified_at': now}, where: 'sorteo_id = ? AND num = ?', whereArgs: [sorteoId, n]);
    }
    await batch.commit(noResult: true);
  }
}
