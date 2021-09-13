import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
//
import 'package:qr_reader/models/scan_model.dart';
export 'package:qr_reader/models/scan_model.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  Future<Database?> initDB() async {
    // Path donde almacenaremos la Db
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'scansDb.db');
    // print(path);

    // Creación de la Base de Datos
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Scans(
            id INTEGER PRIMARY KEY,
            tipo TEXT,
            valor TEXT
          )
        ''');
      },
    );
  }

  // Nuevo Scan
  Future<int> newScanRaw(ScanModel nuevoScan) async {
    // Destructuring model
    final id = nuevoScan.id;
    final tipo = nuevoScan.tipo;
    final valor = nuevoScan.valor;

    // Verificar la base de Datos
    final db = await database;

    // INSERTAR
    final res = await db!.rawInsert('''
      INSERT INTO Scans(id, tipo, valor)
      VALUES($id, '$tipo', '$valor')
    ''');

    return res;
  }

  // INSERTAR 2
  Future<int> nuevoScan(ScanModel nuevoScan) async {
    // Esperar que la BD este lista
    final db = await database;
    final res = await db!.insert('Scans', nuevoScan.toJson());
    return res;
  }

  // Obtener un registro
  Future<ScanModel?> getScanById(int id) async {
    final db = await database;
    final res = await db!.query(
      'Scans',
      where: 'id = ?',
      whereArgs: [id],
    );

    return res.isNotEmpty ? ScanModel.fromJson(res.first) : null;
  }

  // Obtener todos los registros
  Future<List<ScanModel>?> getAllScans() async {
    final db = await database;
    final res = await db!.query('Scans');

    return res.isNotEmpty
        ? res.map((scan) => ScanModel.fromJson(scan)).toList()
        : [];
  }

  // Obtener todos los registros(Por tipo)
  Future<List<ScanModel>?> getScansByType(String tipo) async {
    final db = await database;
    final res = await db!.rawQuery(''' 
      SELECT * FROM Scans WHERE tipo = '$tipo'
    ''');

    return res.isNotEmpty
        ? res.map((scan) => ScanModel.fromJson(scan)).toList()
        : [];
  }

  // Actualizar un Scan
  Future<int?> updateScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db!.update(
      'Scans',
      nuevoScan.toJson(),
      where: 'id = ?',
      whereArgs: [nuevoScan.id],
    );
    return res;
  }

  // Borrar un registro
  Future<int> deleteScan(int id) async {
    final db = await database;
    final res = await db!.delete(
      'Scans',
      where: 'id = ?',
      whereArgs: [id],
    );
    return res;
  }

  // Borrar todos los Scans
  Future<int> deleteAllScans() async {
    final db = await database;
    // final res = await db!.delete('Scans');
    final res = await db!.rawDelete('''
      DELETE FROM Scans
    ''');
    return res;
  }
}
