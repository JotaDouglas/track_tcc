import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static const _dbName = 'trackapptcc.db';
  static const _dbVersion = 1; // Altere esse número ao fazer migrations

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Criação inicial do banco
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rota (
        id INTEGER PRIMARY KEY,
        lat_inicial TEXT,
        long_inicial TEXT,
        lat_final TEXT,
        long_final TEXT,
        data_hora TEXT,
        distancia TEXT,
        titulo TEXT
        )
    ''');

    await db.execute('''
      CREATE TABLE rotas_points (
        id INTEGER PRIMARY KEY,
        id_rota INTEGER,
        latitude TEXT,
        longitude TEXT,
        data_hora TEXT
      )
    ''');
  }

  // Migrações de versão
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Exemplo: adicionando uma nova coluna
      await db.execute('ALTER TABLE rotas ADD COLUMN data_hora TEXT');
    }

    if (oldVersion < 3) {
      // Exemplo: criando nova tabela
      await db.execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT
        )
      ''');
    }
  }

  Future<void> limparBanco() async {
    final db = await database;
    await db.delete('rotas');
  }
}
