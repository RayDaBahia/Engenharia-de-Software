class erroLogin implements Exception {
  final String key;

  static const Map<String, String> errors = {
    'dominio_nao_autorizado': 'Desculpe! Apenas email com dominio Uesb.edu.br são permitidos'
  };

  erroLogin(this.key);

  @override
  String toString() {
    return errors[key] ?? 'Ocorreu um erro durante o processo de autenticação.';
  }
}