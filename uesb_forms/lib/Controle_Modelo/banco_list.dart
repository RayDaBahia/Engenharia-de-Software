import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart'; // importando modelo de questão
import 'auth_list.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int tamQuestoesBanco = 0;
  // Pega o usuário logado
  final AuthList? _authList;

  List<Questao> questoesLista = []; // Lista para armazenar questões
  List<Questao> questoesFiltro = []; // lista de questões filtrados
  List<Banco> bancosLista = [];
  List<Banco> bancosFiltro = []; // lista de bancos filtrados

  BancoList([this._authList]);

  // metodo para adicionar a questao na lista
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

      // Usando WriteBatch para adicionar as questões
      WriteBatch batch = _firestore.batch(); // Inicia o batch

      for (var questao in questoes) {
        final questaoRef = bancoRef.collection('questoes').doc();
        batch.set(questaoRef, questao.toMap());
      }

      banco.id = bancoRef.id;

      await batch.commit(); // Executa todas as operações em um único commit
      bancosLista.add(banco);
      notifyListeners();
    }
  }

  Future<void> AtualizarBanco(Banco banco) async {
    final user = _authList?.usuario;

    verificaPreenchimento(questoesLista, banco);

    // Atualiza as informações do banco
    await _firestore
        .collection('usuarios')
        .doc(user!.id)
        .collection('bancos')
        .doc(banco.id)
        .update({
      'nome': banco.nome,
      'descricao': banco.descricao,
    });
    int index = bancosLista.indexWhere((b) => b.id == banco.id);

    bancosLista[index] = banco;

    // Usando WriteBatch para atualizar as questões
    WriteBatch batch = _firestore.batch(); // Inicia o batch

    for (int i = 0; i < min(tamQuestoesBanco, questoesLista.length); i++) {
      final questao = questoesLista[i];

      final questaoRef = _firestore
          .collection('usuarios')
          .doc(user.id)
          .collection('bancos')
          .doc(banco.id)
          .collection('questoes')
          .doc(questao
              .id); // Aqui usamos o ID da questão para garantir a atualização correta

      batch.set(questaoRef,
          questao.toMap()); // Você pode usar set() para criar ou substituir
    }
    for (int i = tamQuestoesBanco; i < questoesLista.length; i++) {
      final questao = questoesLista[i];

      // Adiciona a nova questão normalmente
      await _firestore
          .collection('usuarios')
          .doc(user.id)
          .collection('bancos')
          .doc(banco.id)
          .collection('questoes')
          .add(questao
              .toMap()); // Isso cria um novo documento com um ID gerado automaticamente
    }

    await batch.commit(); // Executa todas as operações em um único commit
    notifyListeners(); // Notifica os ouvintes sobre a atualização
  }

  // Método para criar um banco com questões obrigatórias
  Future<void> SalvarBanco(String nome, String descricao) async {
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
    if (bancosLista.isNotEmpty)
      return; // Se a lista já estiver carregada, não faça a leitura
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

  Future<void> adicionarQuestao(String bancoId, Questao questao) async {
    final user = _authList?.usuario;
    if (user != null) {
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

    questoesLista.clear();
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(bancoId)
        .collection('questoes')
        .get();

    questoesLista.addAll(snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      return Questao.fromMap(data);
    }).toList());

    tamQuestoesBanco = questoesLista.length;

    notifyListeners();
  }

  Future<void> removerQuestao(String? bancoId, Questao questao) async {
    final user = _authList?.usuario;
    if (user != null) {
      if (bancoId != null) {
        final questaoRef = _firestore
            .collection('usuarios')
            .doc(user.id)
            .collection('bancos')
            .doc(bancoId)
            .collection('questoes')
            .doc(questao.id);

        await questaoRef.delete();
      }
    }

    questoesLista.removeWhere((q) => q.id == questao.id);
    notifyListeners();
  }

  // Método para filtrar questões 
  void filtrarQuestoes(String texto) {
    if (texto.isEmpty) {
      questoesFiltro.clear(); 
      notifyListeners();
      return;
    }

    questoesFiltro = questoesLista
        .where((questao) =>
            questao.textoQuestao.toLowerCase().contains(texto.toLowerCase()))
        .toList();

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
      throw Exception('Necessário adicionar opções às questões');
    }
  }

  /////////////////////////////////////////// BANCO DE QUESTÕES ///////////////////////////////////////////////////////

 
  
  Future<void> excluirBanco(String bancoId) async {
    final user = _authList?.usuario;
    if (user != null) {
      final bancoRef = _firestore
          .collection('usuarios')
          .doc(user.id)
          .collection('bancos')
          .doc(bancoId);

      final questoesSnapshot = await bancoRef.collection('questoes').get();
      for (var doc in questoesSnapshot.docs) {
        await doc.reference.delete();
      }

      await bancoRef.delete();
    }
  }

  // Método para filtrar bancos pelo nome
  List<Banco> filtrarBancosPorNome(String nome) {
    if (nome.isEmpty) {
      return []; // Retorna uma lista vazia se o nome for vazio
    }

    return bancosLista.where((banco) {
      return banco.nome.toLowerCase().contains(nome.toLowerCase());
    }).toList();
  }

  // Método para filtrar bancos pelo nome e adicionar à lista bancosFiltro
  void filtrarBanco(String nome) {
    if (nome.isEmpty) {
      bancosFiltro.clear();
      notifyListeners();
      return;
    }

    bancosFiltro = bancosLista
        .where((banco) => banco.nome.toLowerCase().contains(nome.toLowerCase()))
        .toList();

    notifyListeners();
  }
}
