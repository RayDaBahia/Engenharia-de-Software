import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/banco.dart';
import 'package:uesb_forms/Modelo/questao.dart'; // importando modelo de questão
import 'auth_list.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pega o usuário logado
  final AuthList? _authList;

  BancoList([this._authList]);

  // método para adicionar banco e coleção de questões
  Future<void> addBanco(Banco banco, List<Questao> questoes) async {
    final user = _authList?.usuario; // pega o resgistro do usuário 
    if (user != null) {
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
  Future<void> criarBanco(String nome, String descricao, List<Questao> questoes) async {
    final user = _authList?.usuario; // Obtém o usuário logado
    if (user != null) {
       // Cria objeto banco
      final novoBanco = Banco(
        id: '', // espero que o firebase crie o id
        nome: nome,
        descricao: descricao,
      );

      // adiciona banco e questões
      await addBanco(novoBanco, questoes);

      notifyListeners();
      
    }
  }

  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // ESTE MÉTODO NÃO ESTÁ SENDO USADO, EU TROUXE PRA CÁ PARA PODER IMPLEMENTAR DEPOIS, SERVE PARA ADIOCAR QUESTÕES EM UM BANCO SEPARADO
  
  Future<void> adicionarQuestao(String bancoId, Questao questao) async {
    final user = _authList?.usuario; 
    if (user != null) {
      // Adiciona a questão à subcoleção questoes do banco
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
  Future<List<Banco>> getBancos() async {
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
    return snapshot.docs.map((doc) {
      return Banco(
        id: doc.id,
        nome: doc['nome'],
        descricao: doc['descricao'],
      );
    }).toList();
  }
}
