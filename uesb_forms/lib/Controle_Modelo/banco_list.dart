import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/banco.dart';
import 'package:uesb_forms/Modelo/questao.dart'; // importando modelo de questão
import 'auth_list.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pega o usuário logado
  final AuthList? _authList;
  List<Questao> questoesLista = []; // Lista para armazenar questões

  List<Banco> bancosLista = [];
  List<Banco> bancosFiltro = []; // lista de bancos filtrados

  BancoList([this._authList]);

  // metodo para adicionar a questao na lisya
  void adicionarQuestaoNaLista(Questao questao) {
    final index = questoesLista.indexWhere((q) => q.id == questao.id);

    if (index >= 0) {
      questoesLista[index] = questao;
    } else {
      questao.id = Random().nextInt(1000000).toString();
      questoesLista.add(questao);
    }

    notifyListeners();
  }

  // metodo para limpar lista de questões
  void limparListaQuestoes() {
    questoesLista.clear();
  }

  // Método para adicionar banco e coleção de questões
  Future<void> addBanco(Banco banco, List<Questao> questoes) async {
    final user = _authList?.usuario; // pega o registro do usuário
    if (user != null) {
      verificaPreenchimento(questoes, banco);

      // Adiciona o banco
      final bancoRef = await _firestore
          .collection('usuarios') // Coleção dos usuários
          .doc(user.id) // ID do usuário
          .collection('bancos') // Subcoleção 'bancos' do usuário
          .add({
        'nome': banco.nome,
        'descricao': banco.descricao,
      });

      // Cria a subcoleção 'questoes' e adiciona as questões

      for (var questao in questoes) {
        await bancoRef.collection('questoes').add(questao.toMap());
      }
      notifyListeners();
    }
  }

  // Método para criar um banco com questões obrigatórias
  Future<void> SalvarBanco(String nome, String descricao) async {
    // copy
    final user = _authList?.usuario; // Obtém o usuário logado
    if (user != null) {
      // Cria objeto banco
      final novoBanco = Banco(
        id: '', // espero que o firebase crie o id
        nome: nome,
        descricao: descricao,
      );

      // Adiciona banco e questões
      await addBanco(novoBanco, questoesLista);

      // Limpa a lista de questões após salvar o banco
      limparListaQuestoes();

      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////GET BANCO //////////////////////////////////////////////////////
  Future<void> getBanco() async {
    final user = _authList?.usuario;
    if (user == null) {
      throw Exception('não autenticado');
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .get();

    bancosLista.clear();

    bancosLista.addAll(snapshot.docs.map((doc) {
      final data = doc.data();
      return Banco(
        id: doc.id,
        nome: data['nome'] ?? '',
        descricao: data['descricao'] ?? '',
      );
    }).toList());

    notifyListeners();
  }

  // void getBanco() {
  //   final user = _authList?.usuario; // Obtém o usuário logado
  //   if (user == null) {
  //     throw Exception('Usuário não autenticado');
  //   }

  //   // Busca todos os bancos do usuário no Firestore
  //   _firestore
  //       .collection('usuarios')
  //       .doc(user.id)
  //       .collection('bancos')
  //       .get()
  //       .then((snapshot) {
  //     // Limpa a lista antes de adicionar novos bancos
  //     bancosLista.clear();

  //     // Converte os documentos retornados em uma lista de objetos Banco
  //     bancosLista.addAll(snapshot.docs.map((doc) {
  //       final data = doc.data();
  //       return Banco(
  //         id: doc.id,
  //         nome: data['nome'] ?? '',
  //         descricao: data['descricao'] ?? '',
  //       );
  //     }).toList());

  //     // Notifica os listeners para atualizar a interface, se necessário
  //     notifyListeners();
  //   }).catchError((error) {
  //     // Lida com erros, se houver
  //     print('Erro ao buscar bancos: $error');
  //   });
  // }

  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // ESTE MÉTODO NÃO ESTÁ SENDO USADO, EU TROUXE PRA CÁ PARA PODER IMPLEMENTAR DEPOIS, SERVE PARA ADICIONAR QUESTÕES EM UM BANCO SEPARADO

  Future<void> adicionarQuestao(String bancoId, Questao questao) async {
    final user = _authList?.usuario;
    if (user != null) {
      // adiciona questão a subcoleção de questões de um banco em expecífico
      await _firestore
          .collection('usuarios')
          .doc(user.id)
          .collection('bancos')
          .doc(bancoId)
          .collection('questoes')
          .add(questao.toMap());

      notifyListeners();
    }
  }

  Future<void> buscarQuestoesBancoNoBd(String? bancoId) async {
    final user = _authList?.usuario;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Obtendo as questões do banco específico
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(bancoId)
        .collection(
            'questoes') // Adicione a subcoleção onde as questões estão armazenadas
        .get();

    // Convertendo os documentos em uma lista de Questao
    questoesLista.addAll(snapshot.docs.map((doc) {
      // Certificando-se de que os dados estão no formato correto
      final data = doc.data();
      data['id'] = doc.id;

      return Questao.fromMap(data); // Assumindo que você tem um método fromMap
    }).toList()); // Convertendo o Iterable em uma lista

    notifyListeners();
  }

  Future<void> removerQuestao(String? bancoId, Questao questao) async {
    final user = _authList?.usuario;
    if (user != null) {
      // Verifica se o bancoId não é nulo
      if (bancoId != null) {
        // Obtém a referência do documento da questão diretamente
        final questaoRef = _firestore
            .collection('usuarios')
            .doc(user.id)
            .collection('bancos')
            .doc(bancoId)
            .collection('questoes')
            .doc(questao.id); // Usando o ID da questão

        // Tenta remover a questão do Firestore

        await questaoRef.delete(); // Remove o documento diretamente
      }
    }

    // Remove a questão da lista local
    questoesLista.removeWhere((q) => q.id == questao.id);

    notifyListeners();
  }

  void verificaPreenchimento(List<Questao> questoes, Banco banco) {
    bool verificaPgt = questoes.any((q) => q.textoQuestao.isEmpty);
    bool verificaCampos = questoes.any((q) {
      return q.opcoes?.every((opcao) => opcao.trim().isEmpty) ?? false;
    });

    if (banco.nome.isEmpty) {
      throw Exception('O Banco deve ter um nome');
    }

    if (verificaPgt) {
      throw Exception('Campo pergunta é obrigatório');
    }
    if (verificaCampos) {
      throw Exception('Necessário adicionar opções as questões');
    }
  }

//////////// EXCLUIR BANCO DE QUESTÕES ////////////////////

  Future<void> excluirBanco(String bancoId) async {
    final user = _authList?.usuario;
    if (user != null) {
      // Referência do banco
      final bancoRef = _firestore
          .collection('usuarios')
          .doc(user.id)
          .collection('bancos')
          .doc(bancoId);

      // Busca e exclui todas as questões na subcoleção
      final questoesSnapshot = await bancoRef.collection('questoes').get();
      for (var doc in questoesSnapshot.docs) {
        await doc.reference.delete(); // Exclui cada questão
      }

      // Após excluir as questões, exclui o banco
      await bancoRef.delete();
    }
  }

  // Método para filtrar bancos pelo nome
  List<Banco> filtrarBancosPorNome(String nome) {
    if (nome.isEmpty) {
      return []; // Retorna uma lista vazia se o nome for vazio
    }

    // Filtra a lista de bancos com base na string de busca (case-insensitive)
    return bancosLista.where((banco) {
      return banco.nome.toLowerCase().contains(nome.toLowerCase());
    }).toList();
  }

  // Método para filtrar bancos pelo nome e adicionar à lista bancosFiltro
  void filtrarBanco(String nome) {
   
    bancosFiltro.clear();
 
    if (nome.isNotEmpty) {
      bancosFiltro.addAll(bancosLista.where((banco) {
        return banco.nome.toLowerCase().contains(nome.toLowerCase());
      }).toList());
    }

    notifyListeners();
  }
}
