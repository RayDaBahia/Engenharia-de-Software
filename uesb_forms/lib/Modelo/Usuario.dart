class Usuario {
  final String? _nome;
  final String? _email;
  final String? _fotoPerfilUrl;
  final String? _id;

  Usuario({
    required String id,
    required String nome,
    required String email,
    required String fotoPerfilUrl,
  })  : _id = id,
        _nome = nome,
        _email = email,
        _fotoPerfilUrl = fotoPerfilUrl;

  // Getters para acessar os campos privados
  String? get nome => _nome;
  String? get email => _email;
  String? get fotoPerfilUrl => _fotoPerfilUrl;
  String? get id => _id;
}
