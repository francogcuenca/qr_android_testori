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

  Widget _roundedBtn({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
      final cantidadStr = p.cantidad.toString().padLeft(6, '0');
      final numMedioStr = p.numMedio.toString().padLeft(4, '0');
      return "${p.numOt}${p.codPieza}${numMedioStr}${cantidadStr}${p.lote}";
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
      setState(() => picked.clear());
      await _savePickedToPrefs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando: ${res.statusCode}')),
      );
      debugPrint('Error body: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Picker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BOTONES SUPERIORES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundedBtn(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  onTap: _scanSingle,
                ),
                _roundedBtn(
                  icon: Icons.play_arrow,
                  label: sending ? "Enviando..." : "Enviar",
                  color: const Color.fromARGB(255, 68, 147, 179),
                  onTap: sending ? null : _sendMovimiento,
                ),
                _roundedBtn(
                  icon: Icons.list_alt,
                  label: 'Ver Mov.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovimientosScreen()),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // SELECTS
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: almacenOrigen,
                      decoration: InputDecoration(labelText: "Almacén origen"),
                      items: almacenes.map((a) {
                        final id = a['id'].toString();
                        final name = a['nombre'] ?? a['descripcion'] ?? id;
                        return DropdownMenuItem(value: id, child: Text(name));
                      }).toList(),
                      onChanged: (v) => setState(() => almacenOrigen = v),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: almacenDestino,
                      decoration: InputDecoration(labelText: "Almacén destino"),
                      items: almacenes.map((a) {
                        final id = a['id'].toString();
                        final name = a['nombre'] ?? a['descripcion'] ?? id;
                        return DropdownMenuItem(value: id, child: Text(name));
                      }).toList(),
                      onChanged: (v) => setState(() => almacenDestino = v),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // LISTA
            Expanded(
              child: picked.isEmpty
                  ? Center(child: Text('No hay artículos escaneados'))
                  : ListView.builder(
                      itemCount: picked.length,
                      itemBuilder: (_, idx) {
                        final p = picked[idx];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (p.descripcionArti != null &&
                                    p.descripcionArti!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      p.descripcionArti!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                _row('OT', p.numOt),
                                _row('Cod. Pieza', p.codPieza),
                                _row('Num. Medio', p.numMedio.toString()),
                                _row('Cantidad', p.cantidad.toString()),
                                _row('Lote', p.lote),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeAt(idx),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
