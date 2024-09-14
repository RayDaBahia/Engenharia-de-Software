import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/Meus_Formularios.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthList>(context, listen: false);

    Future<void> _loginWithGoogle(AuthList authList) async {
      try {
        await authList.handleGoogleSignIn();

        Navigator.pushReplacementNamed(context, Rotas.MEUS_FORMULARIOS);
      } catch (error) {
        //  tratar com _showErrorDialog
      }
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(10, 10, 10, 1),
              Color.fromRGBO(81, 45, 134, 1),
            ],
            stops: [0.4, 0.9],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                ),
                Text(
                  'Bem-vindo',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30),
                ),
                Text(
                  'ao Uesb Form',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Image.asset(
              "images/brasaoUesb.png",
              height: 200,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () => _loginWithGoogle(authUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                        width: 2), // Borda preta
                    elevation: 0, // Remove a sombra
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "images/google.png",
                        height: 25,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                      ),
                      const Text(
                        "Google",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

/*

SizedBox(
              height: 30,
              child: SignInButton(
                Buttons.google,
                onPressed: () => _loginWithGoogle(authUser),
                text: 'Google',
              ),
            ),



 */
