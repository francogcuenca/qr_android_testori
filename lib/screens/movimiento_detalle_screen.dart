import 'package:flutter/material.dart';

class MovimientoDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> movimiento;
  const MovimientoDetalleScreen({super.key, required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final id = movimiento['id'] ?? movimiento['movimiento_id'] ?? '—';
    final origen = movimiento['almacen_origen']?.toString() ?? '—';
    final destino = movimiento['almacen_destino']?.toString() ?? '—';
    final creador =
        movimiento['creador_id']?.toString() ??
        movimiento['creador']?.toString() ??
        '—';
    final fecha = movimiento['fecha'] ?? movimiento['created_at'] ?? '';
    final items = movimiento['items'] ?? movimiento['qrs'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Mov $id')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movimiento #$id',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Origen: $origen'),
                    Text('Destino: $destino'),
                    Text('Creador: $creador'),
                    Text('Fecha: $fecha'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text('No hay items en este movimiento'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (_, i) {
                        final it = items[i];
                        // it puede ser Map o array; asumimos Map con las columnas de tstr_pick_qr
                        final numOt =
                            it['num_ot']?.toString() ??
                            it['numOt']?.toString() ??
                            '—';
                        final codPieza =
                            it['cod_pieza']?.toString() ??
                            it['codPieza']?.toString() ??
                            '—';
                        final cantidad = it['cantidad']?.toString() ?? '—';
                        final lote = it['lote']?.toString() ?? '—';
                        return ListTile(
                          leading: Icon(Icons.inventory_2),
                          title: Text('$codPieza — OT $numOt'),
                          subtitle: Text('Cant: $cantidad — Lote: $lote'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
