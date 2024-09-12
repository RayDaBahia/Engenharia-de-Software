import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:uesb_forms/Modelo/auth_list.dart';
import 'package:uesb_forms/Telas/Meus_Formularios.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:provider/provider.dart';



class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    final authUser=Provider.of<AuthList>(context, listen: false);

    Future<void> _loginWithGoogle(AuthList authList) async {
        try {
          await authList.handleGoogleSignIn();

          Navigator.pushNamed(context, Rotas.MEUS_FORMULARIOS);

        } catch (error) {
          //  tratar com _showErrorDialog
        
        }
      }


    return Scaffold(
      appBar: AppBar(
        title: Text('Google Login'),
      ),
      body:  Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          onPressed:()=>_loginWithGoogle(authUser),
          text: 'Login com o Google',
        ),
      ),
    ),
  
    );
  }




}

  