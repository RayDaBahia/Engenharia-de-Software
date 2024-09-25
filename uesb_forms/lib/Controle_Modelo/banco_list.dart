import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/banco.dart';
import 'package:uesb_forms/Modelo/questao.dart'; // importando modelo de questão
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'auth_list.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pega o usuário logado
  final AuthList? _authList;
  List<Questao> questoesLista = []; // Lista para armazenar questões
  List<Banco>  bancosLista =[];

  BancoList([this._authList]);

  // metodo para adicionar a questao na lisya
  void adicionarQuestaoNaLista(Questao questao) {
    final index = questoesLista.indexWhere((q) => q.id == questao.id);

    if (index >= 0) {
      questoesLista[index] = questao;
    } else {

       questao.id= Random().nextInt(1000000).toString();
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

     bancosLista.add(banco);

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

  // Método para retornar os bancos do usuário
  Future<void>  getBancos() async {
    final user = _authList?.usuario; //Obtém o usuário logado
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Busca todos os bancos do usuário no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .get();

    // Converte os documentos retornados em uma lista de objetos Banco
     bancosLista.addAll(snapshot.docs.map((doc) {
      return Banco(
        id: doc.id,
        nome: doc['nome'],
        descricao: doc['descricao'],
      );
    }).toList());

    notifyListeners();
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

      if (data is Map<String, dynamic>) {
        return Questao.fromMap(
            data); // Assumindo que você tem um método fromMap
      } else {
        throw Exception('Formato de dados inválido');
      }
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
       return  q.opcoes?.every((opcao) => opcao.trim().isEmpty) ?? false;


    });

    if(banco.nome.isEmpty){
      throw Exception('O Banco deve ter um nome');
    }

    if (verificaPgt) {
      throw Exception('Campo pergunta é obrigatório');
    }
    if (verificaCampos) {
      throw Exception('Necessário adicionar opções as questões');
    }
  }
}
