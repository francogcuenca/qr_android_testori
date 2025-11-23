import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'movimiento_detalle_screen.dart'; // importamos la pantalla de detalle

class MovimientosScreen extends StatefulWidget {
  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  List movimientos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getMovimientos();
    setState(() {
      movimientos = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movimientos')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : movimientos.isEmpty
          ? Center(child: Text('No hay movimientos'))
          : ListView.separated(
              padding: EdgeInsets.all(12),
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemCount: movimientos.length,
              itemBuilder: (context, idx) {
                final m = movimientos[idx];

                // Asegurate que tu backend devuelva: id, almacen_origen, almacen_destino, creador_id, fecha_creacion, items (o qrs)
                final id = m['id'] ?? m['movimiento_id'] ?? idx;
                final origen =
                    m['almacen_origen']?.toString() ??
                    (m['origen']?.toString() ?? '—');
                final destino =
                    m['almacen_destino']?.toString() ??
                    (m['destino']?.toString() ?? '—');
                final fecha = m['fecha_creacion'] ?? m['created_at'] ?? '';
                final items = m['items'] ?? m['qrs'] ?? [];

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
                        Text('Items: ${items.length}    Fecha: $fecha'),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navegamos al detalle pasando el objeto movimiento completo
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
    );
  }
}
