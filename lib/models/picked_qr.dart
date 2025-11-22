class PickedQr {
  final String numOt;
  final String codPieza;
  final int cantidad;
  final String lote;
  final String creador; // si no viene en el QR, se deja vacio

  PickedQr({
    required this.numOt,
    required this.codPieza,
    required this.cantidad,
    required this.lote,
    this.creador = '',
  });

  Map<String, dynamic> toJson() => {
    'num_ot': numOt,
    'cod_pieza': codPieza,
    'cantidad': cantidad,
    'lote': lote,
    'creador': creador,
  };

  static PickedQr fromBarcodeString(String s) {
    // Asumimos formato fijo: 5 + 10 + 8 + 8 = 31 chars
    final clean = s.trim();
    if (clean.length < 31) {
      throw FormatException('Código QR inválido. Longitud menor a 31.');
    }
    final numOt = clean.substring(0, 5);
    final codPieza = clean.substring(5, 15);
    final cantidadStr = clean.substring(15, 23);
    final lote = clean.substring(23, 31);

    final cantidad = int.tryParse(cantidadStr) ?? 0;

    return PickedQr(
      numOt: numOt,
      codPieza: codPieza,
      cantidad: cantidad,
      lote: lote,
    );
  }
}
