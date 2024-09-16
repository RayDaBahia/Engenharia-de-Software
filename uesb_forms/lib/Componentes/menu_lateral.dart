import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authUser = Provider.of<AuthList>(context, listen: false);

    Future<void> _signoutGoogle() async {
      try {
        await _authUser.handleSignOut();

        Navigator.pushReplacementNamed(context, Rotas.HOME);
      } catch (error) {
        //  tratar com _showErrorDialog
      }
    }

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          AppBar(
            title: const Text(
              'UESB Formulários',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 27, 7, 80),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Meus Formulários'),
            onTap: () {
               Navigator.of(context).pushNamed(Rotas.MEUS_FORMULARIOS);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.storage),
            onTap: () {
              Navigator.of(context).pushNamed(Rotas.MEUS_BANCOS);
            },
            title: Text('Meus Bancos'),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.notifications,
            ),
            onTap: () {},
            title: Text('Notificação'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Conta'),
            onTap: () {},
          ),
          Divider(),
          SizedBox(
            height: 300,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sair'),
            onTap: () {
              _signoutGoogle();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
