import 'dart:developer' as developer;

class PickedQr {
  final String numOt;
  final String codPieza;
  final String numMedio;
  final int cantidad;
  final String lote;
  final String creador; // opcional

  // NUEVO
  String? descripcionArti;

  PickedQr({
    required this.numOt,
    required this.codPieza,
    required this.numMedio,
    required this.cantidad,
    required this.lote,
    this.creador = '',
    this.descripcionArti,
  });

  Map<String, dynamic> toJson() => {
    'num_ot': numOt,
    'cod_pieza': codPieza,
    'num_medio': numMedio,
    'cantidad': cantidad,
    'lote': lote,
    'creador': creador,
    'descripcion': descripcionArti,
  };

  static PickedQr fromBarcodeString(String raw) {
    developer.log('PickedQr.fromBarcodeString - raw: <$raw>');

    final clean = raw.replaceAll(RegExp(r'\s+'), '').trim();

    developer.log('PickedQr.fromBarcodeString - clean: <$clean>');
    developer.log('PickedQr.fromBarcodeString - clean.length: ${clean.length}');

    if (clean.length < 29) {
      throw FormatException(
        'Código QR inválido. Longitud esperada mínima: 29. Recibido: ${clean.length}',
      );
    }

    final sNumOt = clean.substring(0, 5);
    final sCodPieza = clean.substring(5, 15);
    final sCantidad = clean.substring(15, 21);
    final sLote = clean.substring(21, 25);
    final sNumMedio = clean.substring(25, 29);

    developer.log(
      'Parsed substrings -> numOt: <$sNumOt>, codPieza: <$sCodPieza>, numMedio: <$sNumMedio>, cantidad: <$sCantidad>, lote: <$sLote>',
    );

    final cantidad = int.tryParse(sCantidad) ?? 0;

    return PickedQr(
      numOt: sNumOt,
      codPieza: sCodPieza,
      numMedio: sNumMedio,
      cantidad: cantidad,
      lote: sLote,
    );
  }
}
