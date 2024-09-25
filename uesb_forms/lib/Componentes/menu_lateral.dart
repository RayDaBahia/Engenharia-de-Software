import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthList>(context, listen: false);

    Future<void> signoutGoogle() async {
      try {
        await authUser.handleSignOut();

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
            leading: const Icon(Icons.description),
            title: const Text('Meus Formulários'),
            onTap: () {
               Navigator.of(context).pushNamed(Rotas.MEUS_FORMULARIOS);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage),
            onTap: () {
              Navigator.of(context).pushNamed(Rotas.MEUS_BANCOS);
            },
            title: const Text('Meus Bancos'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.notifications,
            ),
            onTap: () {},
            title: const Text('Notificação'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Conta'),
            onTap: () {},
          ),
          const Divider(),
          const SizedBox(
            height: 300,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              signoutGoogle();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
