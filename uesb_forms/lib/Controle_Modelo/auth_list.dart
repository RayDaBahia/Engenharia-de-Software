import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uesb_forms/Excecoes/erro_login.dart';
import 'package:uesb_forms/Modelo/usuario.dart';

class AuthList with ChangeNotifier {

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? _usuario;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
   // Android chave: 92855436550-kp0q3014mf6vnqe087rtfno3q1e42s6f.apps.googleusercontent.com
   // WEb chave : 92855436550-2unp3fm8mo04k6125a3ojnv6212nubgt.apps.googleusercontent.com
    clientId: '92855436550-kp0q3014mf6vnqe087rtfno3q1e42s6f.apps.googleusercontent.com',
    hostedDomain: 'uesb.edu.br'
  );
  // instancia que representa o usuario autenticado
  User? _user;

  // Construtor da classe
  AuthList() {
    // Escuta mudanças no estado de autenticação (login/logout)
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Notifica ouvintes sobre mudanças de estado
    });

    // Escuta mudanças no token de autenticação do usuário
    _auth.idTokenChanges().listen((User? user) {
      notifyListeners(); // Notifica ouvintes quando o token muda
    });
  }

  // Método para autenticar com Google
  Future<void> handleGoogleSignIn() async {
    
    final GoogleUser = await _googleSignIn.signIn();
    if (GoogleUser == null) return;

  
    final GoogleAuth = await GoogleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: GoogleAuth.accessToken,
      idToken: GoogleAuth.idToken,
    );

  if (!verificarEmailUesb(GoogleUser.email ?? '')) {
    handleSignOut();
      throw erroLogin( 'dominio_nao_autorizado');
    }

// so vai para o firebase se o dominio tiver ok
 // Realiza o login no Firebase com as credenciais do Google
    UserCredential userCredential = await _auth.signInWithCredential(credential);

    _user = userCredential.user; // Atualiza o _user com o usuário autenticado

    // Após autenticar, cria o objeto Usuario
    _usuario = Usuario(
      id: _user!.uid,
      nome: GoogleUser.displayName.toString(),
      email: GoogleUser.email,
      fotoPerfilUrl: GoogleUser.photoUrl.toString(),
    );

    persistirNoBanco(_usuario!);
    notifyListeners();
}

bool verificarEmailUesb(String email) {
  // Extrair o domínio do e-mail
  final dominio = email.split('@').last.trim();

  // Verificar se o domínio é igual a "uesb.edu.br"
  return dominio == 'uesb.edu.br';
}
  // Método para obter o usuário logado
  Usuario? get usuario {
    return _usuario;
  }

  // Método para realizar logout
  Future<void> handleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();

    _usuario = null; // Reseta o usuário local
    _user = null;

    notifyListeners(); // Notifica ouvintes sobre mudanças
  }

  // Verifica se o usuário está autenticado
  bool isAutenticado() {
    return _auth.currentUser != null;
  }
  
  void persistirNoBanco (Usuario  usuario) async {

    final docRef= _firestore.collection('usuarios').doc(usuario.id);

    final docSnapshot= await docRef.get();

    if(!docSnapshot.exists){

         await _firestore
          .collection('usuarios') // Coleção dos usuários
          .doc(usuario.id).set({
            'nome': usuario.nome,
           'email': usuario.email,
        });
    }
  }
}
