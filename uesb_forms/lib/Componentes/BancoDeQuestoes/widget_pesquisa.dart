import 'package:flutter/material.dart';

class WidgetPesquisa extends StatefulWidget {
  const WidgetPesquisa({super.key});

  @override
  State<WidgetPesquisa> createState() => _WidgetPesquisaState();
}

class _WidgetPesquisaState extends State<WidgetPesquisa> {
  String texto = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    texto = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome do Banco',
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
