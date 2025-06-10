import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/grupo_list.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class GrupoCard extends StatefulWidget {
  final Grupo grupo;
  final bool isLider;

  final bool isFormulario;


  const GrupoCard({super.key, required this.grupo, required this.isLider, this.isFormulario=false});

  @override
  State<GrupoCard> createState() => _GrupoCardState();
}

class _GrupoCardState extends State<GrupoCard> {
  late GrupoList _grupoList;

  void didChangeDependencies() {
    super.didChangeDependencies();
    _grupoList = Provider.of<GrupoList>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        DateFormat("dd/MM/yyyy", 'pt_BR').format(widget.grupo.dataCriacao);

    return GestureDetector(
      onTap: () {
        widget.isFormulario?

        Navigator.pop(context):


        Navigator.pushNamed(
          context,
          Rotas.GRUPO,
          arguments: widget.grupo,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1B0C2F),
              ),
              child: const Icon(Icons.article_outlined, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.grupo.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Criado em: $dataFormatada',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (widget.isLider)
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Rotas.CRIAR_GRUPO, arguments: widget.grupo);
                    },
                    icon: Icon(Icons.edit, color: Colors.grey[600]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _confirmarExclusao(context);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.grupo.id != null) {
                _grupoList.apagarGrupo(widget.grupo.id!);
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
