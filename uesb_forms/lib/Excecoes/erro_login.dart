class erroLogin implements Exception {
  final String key;

  static const Map<String, String> errors = {
    'dominio_nao_autorizado':
        'Desculpe! Apenas email com dominio Uesb.edu.br são permitidos',
  };

  erroLogin(this.key);

  @override
  String toString() {
    // Se a chave não está no mapa, mostra a mensagem original para depuração
    if (errors.containsKey(key)) {
      return errors[key]!;
    } else {
      return 'Ocorreu um erro durante o processo de autenticação.\nDetalhes: $key';
    }
  }
}
