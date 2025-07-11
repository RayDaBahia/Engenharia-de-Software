import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.sizeOf(context);
    var screenHeight = screen.height;
    var screenWidth = screen.width;

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
                    iconTheme: IconThemeData(color: Colors.white),
            title: const Text(
              'UESB Formulários',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor:const Color.fromARGB(255, 45, 12, 68),
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
            leading: const Icon(Icons.group),
            title: const Text('Grupos'),
            onTap: () {
              Navigator.of(context).pushNamed(Rotas.MEUS_GRUPOS);
              
            },
          ),
          const Divider(),
          /*ListTile(
            leading: const Icon(
              Icons.notifications,
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(Rotas.CRUD_BANCO); // É SÓ PRA TESTAR POR ENQUANTO
            },
            title: const Text('Notificações'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Conta'),
            onTap: () {},
          ),
          const Divider(),*/
          SizedBox(
            height: screenHeight * 0.2,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              signoutGoogle();
            },
          ),
      
        ],
      ),
    );
  }
}
