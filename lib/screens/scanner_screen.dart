import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/picked_qr.dart';

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
      // El modelo ya limpia espacios y parsea correctamente
      final pq = PickedQr.fromBarcodeString(raw);

      if (widget.singleMode) {
        Navigator.of(context).pop(pq);
        return;
      }

      // acá podrías guardar el QR en SharedPreferences si querés
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR inválido: formato incorrecto')),
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
                padding: const EdgeInsets.all(12),
                color: Colors.black45,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
