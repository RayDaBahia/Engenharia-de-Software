import 'package:flutter/material.dart';


class WidgetMultiplaEscolha extends StatefulWidget {


  const WidgetMultiplaEscolha({Key? key}) : super(key: key);

  @override
  State<WidgetMultiplaEscolha> createState() => _WidgetMultiplaEscolhaState();
}

class _WidgetMultiplaEscolhaState extends State<WidgetMultiplaEscolha> {
  List<int> _indices = [];
  List<TextEditingController> _controllers = [];
  TextEditingController _perguntaController = TextEditingController();

 

  void _adicionarOpcao() {
    setState(() {
      int index = _indices.length;
      _indices.add(index);
      _controllers.add(TextEditingController());
    });
  }

  void _removerOpcao(int index) {
    setState(() {
      int controllerIndex = _indices.indexOf(index);
      _indices.remove(index);
      _controllers.removeAt(controllerIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _perguntaController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Digite sua pergunta aqui',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: () {
                      // Implementar funcionalidade para adicionar imagem
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: _indices.map((index) {
                  return Row(
                    key: ValueKey<int>(index),
                    children: [
                      Icon(Icons.check_box),
                      Expanded(
                        child: TextField(
                          controller: _controllers[_indices.indexOf(index)],
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Digite sua opção aqui',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _removerOpcao(index);
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _adicionarOpcao,
                    child: Text("Adicionar outra opção"),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _indices.clear();
                        _controllers.clear();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
