import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:uesb_forms/Modelo/Usuario.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/Meus_Formularios.dart';
import 'package:uesb_forms/Utils/rotas.dart';


class AuthList with ChangeNotifier {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? usuario;


  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId:'92855436550-2unp3fm8mo04k6125a3ojnv6212nubgt.apps.googleusercontent.com' );

  User? _user;

  Future<void> handleGoogleSignIn() async {

/*


Ao inicializar a classe (por exemplo, ao iniciar o aplicativo), 
o Flutter já estará monitorando o estado de autenticação e tokens do Firebase.

*/
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


    final GoogleUser = await _googleSignIn.signIn();
    if (GoogleUser == null) return; 


    final GoogleAuth = await GoogleUser.authentication;


    final credential = GoogleAuthProvider.credential(
      accessToken: GoogleAuth.accessToken,

   
      idToken: GoogleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);


          // após autenticar cria o usuario
     usuario = Usuario(
      nome: GoogleUser.displayName,
      email: GoogleUser.email,
      fotoPerfilUrl: GoogleUser.photoUrl,
    );

    notifyListeners();


}

/*

O estado do usuário é resetado após o logout, 
e o método notifyListeners() é chamado para notificar os widgets que dependem dessa classe sobre a mudança.

*/



  Future<void> handleSignOut() async {
    
      await _auth.signOut();
      await _googleSignIn.signOut();
    
  
  }




  bool isAuticado(){

      return _auth.currentUser != null;
  }

 





}
