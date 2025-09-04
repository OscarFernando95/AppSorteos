import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sorteos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sorteos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE numeros(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sorteoId INTEGER,
        numero INTEGER,
        estado TEXT,
        celular TEXT,
        FOREIGN KEY (sorteoId) REFERENCES sorteos(id)
      )
    ''');
  }

  // ------------------ SORTEOS ------------------

  Future<List<Map<String, dynamic>>> getAllSorteos() async {
    final db = await instance.database;
    return await db.query('sorteos', orderBy: 'id DESC');
  }

  Future<int> createNewSorteo(String fecha) async {
    final db = await instance.database;
    final id = await db.insert('sorteos', {'fecha': fecha});

    // Crear números para el sorteo (por ejemplo del 1 al 100)
    for (int i = 1; i <= 100; i++) {
      await db.insert('numeros', {
        'sorteoId': id,
        'numero': i,
        'estado': 'Disponible',
        'celular': null,
      });
    }

    return id;
  }

  // ------------------ NUMEROS ------------------

  Future<List<Map<String, dynamic>>> getNumbersBySorteoId(int sorteoId) async {
    final db = await instance.database;
    return await db.query(
      'numeros',
      where: 'sorteoId = ?',
      whereArgs: [sorteoId],
      orderBy: 'numero ASC',
    );
  }

  Future<int> updateNumber(int id, String? celular) async {
    final db = await instance.database;
    final estado = (celular == null || celular.isEmpty) ? 'Disponible' : 'Vendido';

    return await db.update(
      'numeros',
      {
        'estado': estado,
        'celular': celular,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
