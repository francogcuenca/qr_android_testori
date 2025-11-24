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

  void _syncRange() {
    // Si no hay ambos, no armo rango
    if (desde == null || hasta == null) {
      setState(() => selectedRange = null);
      return;
    }

    // Si el usuario elige mal el orden, lo corregimos
    final start = DateTime(desde!.year, desde!.month, desde!.day, 0, 0, 0);
    final end = DateTime(hasta!.year, hasta!.month, hasta!.day, 23, 59, 59);

    if (start.isAfter(end)) {
      // Si desde > hasta, invertimos
      setState(() {
        selectedRange = DateTimeRange(start: end, end: start);
        // Y ajustamos los campos visuales también
        desde = selectedRange!.start;
        hasta = selectedRange!.end;
      });
      return;
    }

    // Asignación normal
    setState(() {
      selectedRange = DateTimeRange(start: start, end: end);
    });
  }

  // NUEVO: rango de fechas seleccionado (null = sin filtro)
  DateTimeRange? selectedRange;

  DateTime? desde;
  DateTime? hasta;

  String get desdeStr {
    if (desde == null) return "—";
    return "${desde!.day.toString().padLeft(2, '0')}/${desde!.month.toString().padLeft(2, '0')}/${desde!.year}";
  }

  String get hastaStr {
    if (hasta == null) return "—";
    return "${hasta!.day.toString().padLeft(2, '0')}/${hasta!.month.toString().padLeft(2, '0')}/${hasta!.year}";
  }

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

    // Preparamos parámetros para la API
    String? dateFrom;
    String? dateTo;
    if (selectedRange != null) {
      // Mandamos ISO strings (el backend puede parsearlas)
      dateFrom = selectedRange!.start.toIso8601String();
      // Para incluir todo el día final, podés ajustar a 23:59:59 si tu backend no lo hace
      dateTo = selectedRange!.end.toIso8601String();
    }

    final data = await ApiService.getMovimientos(
      creadorId: filtro == 'mios' ? userId : null,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    setState(() {
      movimientos = data;
      loading = false;
    });
  }

  // Abre el picker de rango de fechas
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: selectedRange,
      helpText: 'Seleccioná rango de fechas',
      confirmText: 'Aplicar',
      saveText: 'Aplicar',
    );

    if (picked != null) {
      setState(() => selectedRange = picked);
      await _load();
    }
  }

  Future<void> _pickDesde() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: desde ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => desde = picked);
      _syncRange();
      await _load();
    }
  }

  Future<void> _pickHasta() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: hasta ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => hasta = picked);
      _syncRange();
      await _load();
    }
  }

  // Limpia el rango
  Future<void> _clearRange() async {
    setState(() => selectedRange = null);
    await _load();
  }

  String _rangeDisplayText() {
    if (selectedRange == null) return 'Rango: todos';
    final a = selectedRange!.start;
    final b = selectedRange!.end;
    String fmt(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    return 'Rango: ${fmt(a)} — ${fmt(b)}';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera fila (dropdown)
                Row(
                  children: [
                    Text("Ver:", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      value: filtro,
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text("Todos")),
                        DropdownMenuItem(
                          value: 'mios',
                          child: Text("Solo míos"),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => filtro = v);
                        _load();
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Segunda fila (rangos de fecha)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDesde,
                        child: Text("Desde: $desdeStr"),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickHasta,
                        child: Text("Hasta: $hastaStr"),
                      ),
                    ),
                  ],
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
                      final fecha =
                          m['fecha_creacion'] ??
                          m['fecha'] ??
                          m['fecha_formatted'] ??
                          '';
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
