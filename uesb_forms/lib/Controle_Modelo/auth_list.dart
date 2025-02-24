import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uesb_forms/Excecoes/erro_login.dart';
import 'package:uesb_forms/Modelo/usuario.dart';

class AuthList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? _usuario;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '92855436550-2unp3fm8mo04k6125a3ojnv6212nubgt.apps.googleusercontent.com',
    hostedDomain: 'uesb.edu.br',
  );
  User? _user;

  AuthList() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });

    _auth.idTokenChanges().listen((User? user) {
      notifyListeners();
    });
  }

  /// Autenticação com Google (Android/iOS)
  Future<void> handleGoogleSignIn() async {
    if (kIsWeb) {
      return handleGoogleSignInWeb();
    }

    final GoogleUser = await _googleSignIn.signIn();
    if (GoogleUser == null) return;

    final GoogleAuth = await GoogleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: GoogleAuth.accessToken,
      idToken: GoogleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    _user = userCredential.user;

    _usuario = Usuario(
      id: _user!.uid,
      nome: GoogleUser.displayName.toString(),
      email: GoogleUser.email,
      fotoPerfilUrl: GoogleUser.photoUrl.toString(),
    );

    persistirNoBanco(_usuario!);
    notifyListeners();
  }

  /// Autenticação com Google (Web)
  Future<void> handleGoogleSignInWeb() async {
    if (!kIsWeb) return;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      UserCredential userCredential = await _auth.signInWithPopup(googleProvider);

      User? user = userCredential.user;
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
    await _googleSignIn.signOut();
    _usuario = null;
    _user = null;
    notifyListeners();
  }

  bool isAutenticado() {
    return _auth.currentUser != null;
  }

  void persistirNoBanco(Usuario usuario) async {
    final docRef = _firestore.collection('usuarios').doc(usuario.id);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await _firestore.collection('usuarios').doc(usuario.id).set({
        'nome': usuario.nome,
        'email': usuario.email,
      });
    }
  }
}
