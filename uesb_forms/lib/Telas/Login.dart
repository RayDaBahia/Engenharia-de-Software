import 'package:flutter/foundation.dart'; // Adicione para kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Excecoes/erro_login.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> loginWithGoogle(AuthList authList) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        // Web: Usa signInSilently() ou renderButton()
        await authList.handleGoogleSignInWeb();
      } else {
        // Mobile: Usa signIn normalmente
        await authList.handleGoogleSignIn();
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, Rotas.MEUS_FORMULARIOS);
      }
    } on erroLogin catch (e) {
      String errorMessage = e.toString();
      if (mounted) {
        _showErrorDialog(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthList>(context, listen: false);

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
                onPressed: _isLoading
                    ? null
                    : () => loginWithGoogle(authUser),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255),
                    width: 2,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else
                      Row(
                        children: [
                          Image.asset(
                            "images/google.png",
                            height: 25,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Google",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
