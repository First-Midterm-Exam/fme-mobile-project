abstract final class Formatos {
  static String fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  static String hora(DateTime fecha) {
    final horas = fecha.hour.toString().padLeft(2, '0');
    final minutos = fecha.minute.toString().padLeft(2, '0');
    return '$horas:$minutos';
  }

  static String tamano(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1).replaceAll('.', ',')} MB';
    }
    return '${(bytes / kb).ceil()} KB';
  }

  static String plazo(DateTime meta, {DateTime? hoy}) {
    final base = hoy ?? DateTime.now();
    final inicio = DateTime(base.year, base.month, base.day);
    final fin = DateTime(meta.year, meta.month, meta.day);
    final dias = fin.difference(inicio).inDays;
    return switch (dias) {
      0 => 'Vence hoy',
      1 => 'Falta 1 día',
      -1 => 'Venció hace 1 día',
      > 1 => 'Faltan $dias días',
      _ => 'Venció hace ${-dias} días',
    };
  }
}
