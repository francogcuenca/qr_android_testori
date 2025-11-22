import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
          : ListView.separated(
              itemBuilder: (_, idx) {
                final m = movimientos[idx];
                final id = m['id'] ?? m['movimiento_id'] ?? idx;
                final fecha = m['created_at'] ?? m['fecha'] ?? '';
                final items = m['items'] ?? m['qrs'] ?? [];
                return ListTile(
                  title: Text('Mov $id - ${items.length} items'),
                  subtitle: Text('$fecha'),
                  onTap: () {
                    // podés implementar detalle si querés
                  },
                );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: movimientos.length,
            ),
    );
  }
}
