import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/picked_qr.dart';
import '../services/articulo_service.dart';

class ScannerScreen extends StatefulWidget {
  final bool singleMode;
  const ScannerScreen({super.key, this.singleMode = false});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _processing = false;
  MobileScannerController cameraController = MobileScannerController();

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    setState(() => _processing = true);

    try {
      final pqBase = PickedQr.fromBarcodeString(raw);

      // --- Usar tu servicio existente ---
      final descripcionArti = await ArticuloService.getArticuloDescripcion(
        pqBase.codPieza,
      );

      print('DEBUG: descripcionArti obtenida -> $descripcionArti');

      final pq = PickedQr(
        numOt: pqBase.numOt,
        codPieza: pqBase.codPieza,
        numMedio: pqBase.numMedio,
        cantidad: pqBase.cantidad,
        lote: pqBase.lote,
        descripcionArti: descripcionArti ?? '', // por si viene null
      );

      if (widget.singleMode) {
        Navigator.of(context).pop(pq);
        return;
      }

      // Si no es singleMode, guardalo en memoria o SharedPreferences
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR inválido o artículo no encontrado')),
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear QR'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          if (_processing)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
