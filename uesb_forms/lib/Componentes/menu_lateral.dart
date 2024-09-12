


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MenuLateral extends StatelessWidget {
 


  @override
  Widget build(BuildContext context) {

    final _authUser=Provider.of<AuthList>(context, listen: false);

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
        children: [
          AppBar(
            title: Text('UESB Formulários'),
          ),
          
          SizedBox(height: 100,),

          ListTile(
            leading: Icon(
              Icons.description
              
            ),
            title: Text('Meus Formulários'),
           onTap: (){},
          ),
          Divider(),
           SizedBox(height: 30,),
           ListTile(
            leading: Icon(
              Icons.storage
              
            ),
              onTap: (){},
            title: Text('Meus Bancos'),
          ),
           Divider(),
                 SizedBox(height: 30,),
          ListTile(
            leading: Icon(
              Icons.notifications,
              
              
            ),
            onTap: (){},
            title: Text('Notificação'),
          ),

        Divider(),
         SizedBox(height: 30,),

         ListTile(
            leading: Icon(
              Icons.person
              
            ),
            title: Text('Conta'),
           onTap: (){},
          ),
          Divider(),

          Spacer(),

         ListTile(
            leading: Icon(
              Icons.logout
              
            ),
            title: Text('Sair'),
              onTap: (){
                _signoutGoogle();
                ;},
          ),



        ],
      ),




    );
  }
}