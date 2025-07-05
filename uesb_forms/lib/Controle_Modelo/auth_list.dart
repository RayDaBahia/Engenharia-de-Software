import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart' show GoogleAuthProvider;
import 'package:uesb_forms/Excecoes/erro_login.dart';
import 'package:uesb_forms/Modelo/usuario.dart';

class AuthList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? _usuario;
  User? _user;
  Timer? _debounce;
  String _ultimoEmailPesquisado = "";

  AuthList() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });

    _auth.idTokenChanges().listen((User? user) {
      notifyListeners();
    });
  }

  /// Autenticação com Google (Android/iOS/Web)
  Future<void> handleGoogleSignIn() async {
    try {
      if (kIsWeb) {
        return handleGoogleSignInWeb();
      }

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential userCredential = await _auth.signInWithProvider(
        googleProvider,
      );

      final user = userCredential.user;
      if (user == null) return;

      _usuario = Usuario(
        id: user.uid,
        nome: user.displayName ?? '',
        email: user.email ?? '',
        fotoPerfilUrl: user.photoURL ?? '',
      );

      persistirNoBanco(_usuario!);
      notifyListeners();
    } catch (e) {
      print("Erro ao autenticar com Google: $e");
      throw erroLogin("Falha no login: $e");
    }
  }

  Stream<List<Usuario>> buscarUsuariosPorEmail(
    String email, {
    String? entrevistador,
  }) {
    if (email.isEmpty) {
      return Stream.value([]);
    }

    var query = _firestore
        .collection('usuarios')
        .where('email', isGreaterThanOrEqualTo: email)
        .where('email', isLessThanOrEqualTo: '$email\uf8ff');

    return query.snapshots().map((snapshot) {
      List<Usuario> listaUsuarios = snapshot.docs.map((doc) {
        return Usuario(
          id: doc.id,
          nome: doc['nome'],
          email: doc['email'],
          fotoPerfilUrl: doc['fotoPerfilUrl'] ?? '',
        );
      }).toList();

      if (entrevistador == null) {
        listaUsuarios.removeWhere((u) => u.id == _usuario!.id);
      }

      // Se não encontrar ninguém, mas o email é válido, adiciona manualmente
      if (listaUsuarios.isEmpty && validarEmailUesb(email)) {
        listaUsuarios.add(
          Usuario(id: '', nome: '', email: email, fotoPerfilUrl: ''),
        );
      }
      return listaUsuarios;
    });
  }

  bool validarEmailUesb(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@uesb\.edu\.br$');
    return regex.hasMatch(email.trim());
  }

  Future<Usuario?> buscarUsuarioPorId(String id) async {
    try {
      final snapshot = await _firestore.collection('usuarios').doc(id).get();

      if (snapshot.exists) {
        return Usuario(
          id: snapshot.id,
          nome: snapshot['nome'],
          email: snapshot['email'],
          fotoPerfilUrl: snapshot['fotoPerfilUrl'] ?? '',
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void onSearchChanged(String email, Function(Stream<List<Usuario>>) callback) {
    if (email == _ultimoEmailPesquisado) return;
    _ultimoEmailPesquisado = email;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      callback(buscarUsuariosPorEmail(email));
    });
  }

  Future<void> handleGoogleSignInWeb() async {
    if (!kIsWeb) return;

    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      final user = userCredential.user;
      if (user != null) {
        _usuario = Usuario(
          id: user.uid,
          nome: user.displayName ?? '',
          email: user.email ?? '',
          fotoPerfilUrl: user.photoURL ?? '',
        );
        persistirNoBanco(_usuario!);
        notifyListeners();
      }
    } catch (e) {
      print("Erro ao autenticar com Google no Web: $e");
      throw erroLogin("Falha no login: $e");
    }
  }

  bool verificarEmailUesb(String email) {
    final dominio = email.split('@').last.trim();
    return dominio == 'uesb.edu.br';
  }

  Usuario? get usuario => _usuario;

  Future<void> handleSignOut() async {
    await _auth.signOut();
    _usuario = null;
    _user = null;
    notifyListeners();
  }

  bool isAutenticado() {
    return _auth.currentUser != null;
  }

  void persistirNoBanco(Usuario usuario) async {
    final docRef = _firestore.collection('usuarios').doc(usuario.id);
    await docRef.set({
      'nome': usuario.nome,
      'email': usuario.email,
      'fotoPerfilUrl': usuario.fotoPerfilUrl,
      'id': usuario.id,
    }, SetOptions(merge: true));
  }
}
