const idiomasReconocimiento = ['es_BO', 'es_419', 'es_ES'];
const idiomasLectura = ['es_BO', 'es_419', 'es_US', 'es_MX', 'es_ES'];

String? elegirIdioma(Iterable<String> disponibles, List<String> preferidos) {
  String normalizar(String id) => id.replaceAll('-', '_').toLowerCase();

  final porNormalizado = {for (final id in disponibles) normalizar(id): id};
  for (final preferido in preferidos) {
    final encontrado = porNormalizado[normalizar(preferido)];
    if (encontrado != null) {
      return encontrado;
    }
  }
  for (final MapEntry(key: normalizado, value: id) in porNormalizado.entries) {
    if (normalizado == 'es' || normalizado.startsWith('es_')) {
      return id;
    }
  }
  return null;
}
