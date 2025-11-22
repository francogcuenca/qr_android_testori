import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/picked_qr.dart';
import '../services/api_service.dart';
import 'scanner_screen.dart';
import 'movimientos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PickedQr> picked = [];
  bool sending = false;
  String? almacenOrigen;
  String? almacenDestino;
  List<dynamic> almacenes = [];

  @override
  void initState() {
    super.initState();
    _loadPicked();
    _loadAlmacenes();
  }

  Future<void> _loadAlmacenes() async {
    final list = await ApiService.getAlmacenes();
    setState(() => almacenes = list);
  }

  Future<void> _loadPicked() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('qrs') ?? [];
    final parsed = <PickedQr>[];
    for (final r in raw) {
      try {
        parsed.add(PickedQr.fromBarcodeString(r));
      } catch (_) {}
    }
    setState(() => picked = parsed);
  }

  Future<void> _savePickedToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = picked.map((p) {
      // regenero el string original para persistir (simple)
      final cantidadStr = p.cantidad.toString().padLeft(8, '0');
      return "${p.numOt}${p.codPieza}${cantidadStr}${p.lote}";
    }).toList();
    await prefs.setStringList('qrs', raw);
  }

  Future<void> _scanSingle() async {
    final result = await Navigator.push<PickedQr>(
      context,
      MaterialPageRoute(builder: (_) => ScannerScreen(singleMode: true)),
    );
    if (result != null) {
      setState(() => picked.insert(0, result));
      await _savePickedToPrefs();
    }
  }

  void _removeAt(int idx) async {
    setState(() => picked.removeAt(idx));
    await _savePickedToPrefs();
  }

  Future<void> _sendMovimiento() async {
    if (picked.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No hay QRs para enviar')));
      return;
    }
    if (almacenOrigen == null || almacenDestino == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Seleccioná origen y destino')));
      return;
    }

    setState(() => sending = true);

    final qrsJson = picked.map((p) => p.toJson()).toList();

    final res = await ApiService.postMovimiento(
      almacenOrigen: almacenOrigen!,
      almacenDestino: almacenDestino!,
      qrs: qrsJson,
    );

    setState(() => sending = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Movimiento enviado.')));
      // limpiamos
      setState(() => picked.clear());
      await _savePickedToPrefs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando movimiento: ${res.statusCode}')),
      );
      // opcional: ver body
      debugPrint('Error body: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('QR Picker')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // botones arriba
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _scanSingle,
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text('Scan QR'),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(12)),
                ),
                ElevatedButton.icon(
                  onPressed: sending ? null : _sendMovimiento,
                  icon: Icon(Icons.play_arrow),
                  label: sending ? Text('Enviando...') : Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovimientosScreen()),
                  ),
                  icon: Icon(Icons.list_alt),
                  label: Text('Ver Mov.'),
                ),
              ],
            ),

            SizedBox(height: 12),

            // selects de almacenes
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: almacenOrigen,
                    hint: Text('Almacén origen'),
                    items: almacenes.map((a) {
                      final id = a['id'].toString();
                      final name = a['nombre'] ?? a['descripcion'] ?? id;
                      return DropdownMenuItem(value: id, child: Text(name));
                    }).toList(),
                    onChanged: (v) => setState(() => almacenOrigen = v),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: almacenDestino,
                    hint: Text('Almacén destino'),
                    items: almacenes.map((a) {
                      final id = a['id'].toString();
                      final name = a['nombre'] ?? a['descripcion'] ?? id;
                      return DropdownMenuItem(value: id, child: Text(name));
                    }).toList(),
                    onChanged: (v) => setState(() => almacenDestino = v),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // lista de qrs
            Expanded(
              child: picked.isEmpty
                  ? Center(child: Text('No hay artículos escaneados'))
                  : ListView.separated(
                      itemBuilder: (_, idx) {
                        final p = picked[idx];
                        return ListTile(
                          title: Text('${p.codPieza} — OT ${p.numOt}'),
                          subtitle: Text(
                            'Cant: ${p.cantidad} — Lote: ${p.lote}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeAt(idx),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => Divider(),
                      itemCount: picked.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
