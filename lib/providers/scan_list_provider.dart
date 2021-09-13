import 'package:flutter/material.dart';
import 'package:qr_reader/providers/db_provider.dart';

class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipoSeleccionado = 'http';

  Future<ScanModel> nuevoScan(String valor) async {
    final nuevoScan = ScanModel(valor: valor);
    final id = await DBProvider.db.nuevoScan(nuevoScan);
    nuevoScan.id = id;

    if (tipoSeleccionado == nuevoScan.tipo) {
      // this
      scans.add(nuevoScan);
      notifyListeners();
    }
    return nuevoScan;
  }

  cargarScans() async {
    final allScans = await DBProvider.db.getAllScans();
    scans = [...allScans!];
    notifyListeners();
  }

  cargarScansPorTipo(String tipo) async {
    final allScans = await DBProvider.db.getScansByType(tipo);
    scans = [...allScans!];
    tipoSeleccionado = tipo;
    notifyListeners();
  }

  borrarTodos() async {
    await DBProvider.db.deleteAllScans();
    scans = [];
    notifyListeners();
  }

  borrarScanPorId(int id) async {
    await DBProvider.db.deleteScan(id);
  }
}
