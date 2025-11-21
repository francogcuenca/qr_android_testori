import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _processing = false;

  Future<void> _onDetect(BarcodeCapture barcodes) async {
    if (_processing) return;

    final barcode = barcodes.barcodes.first.rawValue;
    if (barcode == null) return;

    setState(() => _processing = true);

    // Guardar en memoria (lista de códigos)
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList("qrs") ?? [];

    stored.add(barcode);
    await prefs.setStringList("qrs", stored);

    // Mostramos alerta
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("QR agregado: $barcode")));
    }

    // Dejamos procesar otro después de 1 segundo
    await Future.delayed(Duration(seconds: 1));

    setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escanear QR")),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          if (_processing)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.black54,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
