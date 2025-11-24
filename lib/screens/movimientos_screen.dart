import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'movimiento_detalle_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovimientosScreen extends StatefulWidget {
  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  List movimientos = [];
  bool loading = true;

  String filtro = 'todos'; // todos | mios
  int? userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id'); // guardalo cuando logueás

    await _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final data = await ApiService.getMovimientos(
      creadorId: filtro == 'mios' ? userId : null,
    );

    setState(() {
      movimientos = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movimientos')),
      body: Column(
        children: [
          // ====== FILTRO SUPERIOR ======
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Text("Ver:", style: TextStyle(fontSize: 16)),
                SizedBox(width: 12),
                DropdownButton<String>(
                  value: filtro,
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text("Todos")),
                    DropdownMenuItem(value: 'mios', child: Text("Solo míos")),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => filtro = v);
                    _load();
                  },
                ),
              ],
            ),
          ),

          // ====== LISTA ======
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : movimientos.isEmpty
                ? Center(child: Text('No hay movimientos'))
                : ListView.separated(
                    padding: EdgeInsets.all(12),
                    separatorBuilder: (_, __) => SizedBox(height: 8),
                    itemCount: movimientos.length,
                    itemBuilder: (context, idx) {
                      final m = movimientos[idx];

                      final id = m['id'];
                      final origen = m['almacen_origen'];
                      final destino = m['almacen_destino'];
                      final fecha = m['fecha'];
                      final items = m['items'] ?? [];

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          title: Text(
                            'Movimiento #$id',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6),
                              Text('Origen: $origen  →  Destino: $destino'),
                              SizedBox(height: 4),
                              Text('Items: ${items.length}  -  Fecha: $fecha'),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MovimientoDetalleScreen(movimiento: m),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
