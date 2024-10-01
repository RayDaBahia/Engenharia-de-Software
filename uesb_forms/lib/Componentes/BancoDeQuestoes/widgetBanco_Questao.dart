import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/banco.dart';

class WidgetbancoQuestao extends StatelessWidget {

  final Banco banco;
  const WidgetbancoQuestao({super.key, required this.banco});

  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.sizeOf(context);
    var screenWidth = screenSize.width;

    return Padding(
          padding: const EdgeInsets.all(16),

          child: Container(
    width: screenWidth,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.black45,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: Colors.black,
        width: 1.0,
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            banco.nome,
            style: const TextStyle(
              color: Color.fromARGB(255, 27, 7, 80),
              fontSize: 30,
            ),
          ),
          const Divider(
            color: Colors.black,
          ),
           Text(
            banco.descricao,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  )
  
   );



  }
}