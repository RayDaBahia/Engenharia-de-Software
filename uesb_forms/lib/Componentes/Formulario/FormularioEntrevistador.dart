import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

class FormularioEntrevistador extends StatefulWidget {
  final Questionario questionario;
  final VoidCallback? onAplicar;
  final VoidCallback? onTestar;

  const FormularioEntrevistador({
    super.key,
    required this.questionario,
    this.onAplicar,
    this.onTestar,
  });

  @override
  State<FormularioEntrevistador> createState() => _FormularioEntrevistadorState();
}

class _FormularioEntrevistadorState extends State<FormularioEntrevistador> {


  @override
    void initState() {
    super.initState();

    // Chama a verificação ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarEncerramento();
    });
  }
    Future<void> _verificarEncerramento() async {
    final provider = Provider.of<QuestionarioList>(context, listen: false);
    final atualizado = await provider.verificaEncerramento(widget.questionario);
    if (atualizado) {
      debugPrint(
        '✅ Questionário ${widget.questionario.nome} foi encerrado (prazo ou meta atingida).',
      );
    } else {
      debugPrint(
        '🕒 Questionário ${widget.questionario.nome} ainda está ativo.',
      );
    }

    if (atualizado && mounted) {
      setState(() {}); // Atualiza a UI se houve mudança de status
    }
  }
  @override
  Widget build(BuildContext context) {
    final dataPublicacao = widget.questionario.dataPublicacao != null
        ? DateFormat('dd/MM/yyyy').format(widget.questionario.dataPublicacao!)
        : "Não publicado";

    final prazo = widget.questionario.prazo != null
        ? DateFormat('dd/MM/yyyy').format(widget.questionario.prazo!)
        : "Indefinido";
    

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Cabeçalho com gradiente e menu
          Stack(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 103, 52, 139),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 5,
                child: getStatusIcon(widget.questionario),
              ),
            ],
          ),
          // Corpo do card
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.questionario.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Líder: ${widget.questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Publicado em: $dataPublicacao",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  "Prazo: $prazo",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                // Botões principais (sempre visíveis se publicado)
                if (widget.questionario.publicado)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.questionario.ativo)
                        ElevatedButton(
                          onPressed: () => _handleAcao(
                            context,
                            widget.onAplicar,
                            "Aplicar",
                            widget.questionario.senha,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              45,
                              12,
                              68,
                            ),
                          ),
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _handleAcao(
                          context,
                          widget.onTestar,
                          "Testar",
                          widget.questionario.senha,
                        ),
                        child: const Text('Testar'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getStatusIcon(Questionario questionario) {
    final agora = DateTime.now();

    if (!questionario.publicado) {
      return const Row(
        children: [
          Icon(Icons.hourglass_empty, color: Colors.grey, size: 20),
          SizedBox(width: 5),
          Text("Não publicado", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (questionario.encerrado) {
      return const Row(
        children: [
          Icon(Icons.check, color: Colors.red, size: 20),
          SizedBox(width: 5),
          Text("Encerrado", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (!questionario.ativo) {
      return const Row(
        children: [
          Icon(Icons.visibility_off, color: Colors.orange, size: 20),
          SizedBox(width: 5),
          Text("Inativo", style: TextStyle(color: Colors.white)),
        ],
      );
    }
  if (questionario.senha?.isNotEmpty ?? false) {
  return const Row(
    children: [
      Icon(Icons.lock, color: Colors.orange, size: 20),
      SizedBox(width: 5),
      Text("Bloqueado", style: TextStyle(color: Colors.white)),
    ],
  );
}

    if ( questionario.ativo) {
      return const Row(
        children: [
          Icon(Icons.visibility, color: Colors.green, size: 20),
          SizedBox(width: 5),
          Text("Ativo", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    // ✅ Fallback obrigatório
    return const Row(
      children: [
        Icon(Icons.help_outline, color: Colors.white, size: 20),
        SizedBox(width: 5),
        Text("Desconhecido", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Future<void> _handleAcao(
    BuildContext context,
    VoidCallback? callback,
    String acao,
    String? senha,
  ) async {
    if (senha?.isNotEmpty ?? false) {
      final TextEditingController senhaController = TextEditingController();

      final senhaDigitada = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Senha requerida"),
          content: TextField(
            controller: senhaController, // Associa o controlador ao TextField
            obscureText: true,
            decoration: const InputDecoration(hintText: "Digite a senha"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  senhaController.text,
                ); // Retorna a senha digitada
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      );

      if (senhaDigitada == senha) {
        callback?.call();
      } else if (senhaDigitada != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Senha incorreta!")));
      }
    } else {
      callback?.call();
    }
  }
}
