import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart'; // importando modelo de questão
import 'package:uesb_forms/Utils/cloudinary_service.dart'; // ADICIONADO - Import do Cloudinary
import 'auth_list.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService =
      CloudinaryService(); // ADICIONADO - Instância do Cloudinary
  int tamQuestoesBanco = 0;
  // Pega o usuário logado
  final AuthList? _authList;

  List<Questao> questoesLista = []; // Lista para armazenar questões
  List<Questao> questoesFiltro = []; // lista de questões filtrados
  List<Banco> bancosLista = []; // Banco de questões
  List<Banco> bancosFiltro = []; // lista de bancos filtrados

  BancoList([this._authList]);

  // =======================================================================
  // MÉTODOS ADICIONADOS PARA CLOUDINARY (INÍCIO)
  // =======================================================================

  Future<void> _processarImagensQuestoes(
      String userId, String bancoId, List<Questao> questoes) async {
    final batch = _firestore.batch();
    final bancoRef = _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('bancos')
        .doc(bancoId);

    for (final questao in questoes) {
      final questaoRef = bancoRef.collection('questoes').doc(questao.id);

      // Se tem imagem local mas não tem URL, faz upload
      if (questao.imagemLocal != null && questao.imagemUrl == null) {
        try {
          final result = await _cloudinaryService.uploadImage(
            imageBytes: questao.imagemLocal!,
            fileName: 'questao_${questao.id}.jpg',
            questionId: questao.id!,
          );

          if (result != null) {
            questao.imagemUrl = result.url;
            questao.imagemLocal = null;
          }
        } catch (e) {
          debugPrint(
              'Erro ao fazer upload da imagem da questão ${questao.id}: $e');
        }
      }

 
    }
 
  }

  Future<void> _deletarImagemSeExistir(String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final publicId = _extrairPublicId(imageUrl);
        if (publicId != null) {
          await _cloudinaryService.deleteImage(publicId);
        }
      } catch (e) {
        debugPrint('Erro ao deletar imagem do Cloudinary: $e');
      }
    }
  }

  String? _extrairPublicId(String url) {
    final regex = RegExp(r'upload/(?:v\d+/)?([^\.]+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  // =======================================================================
  // MÉTODOS ADICIONADOS PARA CLOUDINARY (FIM)
  // =======================================================================

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
  final user = _authList?.usuario;
  if (user != null) {
    verificaPreenchimento(questoes, banco);

    // Adiciona o banco
    final bancoRef = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .add({
      'nome': banco.nome,
      'descricao': banco.descricao,
    });

    banco.id = bancoRef.id;

    // Processa upload de imagens antes de salvar
    await _processarImagensQuestoes(user.id!, bancoRef.id, questoes);

    for (var questao in questoes) {
      // Remove o ID se já tiver, pois usaremos o do Firebase
      questao.id = null;
      questao.bancoId = bancoRef.id;

      final docRef = await bancoRef.collection('questoes').add(questao.toMap());

      // Atualiza o campo `id` no próprio documento no Firestore
      await docRef.update({'id': docRef.id});

      // E atualiza também no objeto local
      questao.id = docRef.id;
    }

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

    // ADICIONADO: Processa imagens antes de atualizar
    await _processarImagensQuestoes(user.id!, banco.id!, questoesLista);

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
      // ADICIONADO: Upload de imagem se necessário
      if (questao.imagemLocal != null && questao.imagemUrl == null) {
        try {
          final result = await _cloudinaryService.uploadImage(
            imageBytes: questao.imagemLocal!,
            fileName: 'questao_${questao.id}.jpg',
            questionId: questao.id!,
          );

          if (result != null) {
            questao.imagemUrl = result.url;
            questao.imagemLocal = null;
          }
        } catch (e) {
          debugPrint('Erro ao fazer upload da imagem: $e');
        }
      }

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

  // 🔹 1. Remove da lista local (sempre faz isso)
  questoesLista.removeWhere((q) => q.id == questao.id);
  notifyListeners();

  // 🔹 2. Se bancoId é nulo, não acessa Firestore
  if (bancoId == null || bancoId.isEmpty) {
    print('[removerQuestao] Questão removida apenas localmente (bancoId nulo)');
    return;
  }

  // 🔹 3. Se bancoId existe, remove no Firestore também
  if (user == null) {
    print('[removerQuestao] Usuário não autenticado.');
    return;
  }

  try {
    if (questao.imagemUrl != null) {
      await _deletarImagemSeExistir(questao.imagemUrl);
    }

    final questaoRef = _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(bancoId)
        .collection('questoes')
        .doc(questao.id);

    await questaoRef.delete();

    print('[removerQuestao] Questão removida do Firestore.');
  } catch (e) {
    print('[removerQuestao] Erro ao remover do Firestore: $e');
  }
}

  // Método para filtrar questões
  List<Questao> filtrarQuestoes(String texto) {
    if (texto.isEmpty) {
      questoesFiltro.clear();
    }

    questoesFiltro = questoesLista
        .where((questao) =>
            questao.textoQuestao.toLowerCase().contains(texto.toLowerCase()))
        .toList();

        
    notifyListeners();

    return questoesFiltro;

  }

  void verificaPreenchimento(List<Questao> questoes, Banco banco) {
  

    if (banco.nome.isEmpty) {
      throw Exception('O Banco deve ter um nome');
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

      // ADICIONADO: Primeiro obtém as questões para deletar imagens
      final questoesSnapshot = await bancoRef.collection('questoes').get();
      final questoes = questoesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Questao.fromMap(data);
      }).toList();

      // ADICIONADO: Deleta todas as imagens associadas
      for (final questao in questoes) {
        if (questao.imagemUrl != null) {
          await _deletarImagemSeExistir(questao.imagemUrl);
        }
      }

      // Exclui todas as questões associadas ao banco
      final batch = _firestore.batch();
      for (var doc in questoesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Exclui o próprio banco
      await bancoRef.delete();

      // Remove o banco da lista local e notifica ouvintes
      bancosLista.removeWhere((banco) => banco.id == bancoId);
      notifyListeners(); // Atualiza a interface
    }
  }

  Future<void> duplicarBanco(String bancoId) async {
    final user = _authList?.usuario;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // 1. Buscar o banco original
    final bancoOriginalDoc = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(bancoId)
        .get();

    if (!bancoOriginalDoc.exists) {
      throw Exception('Banco não encontrado');
    }

    final bancoOriginalData = bancoOriginalDoc.data()!;
    final bancoOriginal = Banco(
      id: bancoOriginalDoc.id,
      nome: bancoOriginalData['nome'],
      descricao: bancoOriginalData['descricao'],
    );

    // 2. Buscar as questões associadas ao banco original
    final questoesSnapshot = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(bancoId)
        .collection('questoes')
        .get();

    final List<Questao> questoesParaDuplicar = questoesSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Recupera o ID da questão original
      return Questao.fromMap(data);
    }).toList();

    // 3. Criar um novo banco com nome modificado
    final bancoDuplicado = Banco(
      id: '',
      nome: '${bancoOriginal.nome} - Cópia',
      descricao: bancoOriginal.descricao,
    );

    // 4. Adicionar o novo banco e as questões duplicadas ao Firestore
    await addBanco(bancoDuplicado, questoesParaDuplicar);
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

  Future<Questao?> buscarQuestaoEspecifica(
      String bancoId, String questaoId) async {
    final user = _authList?.usuario;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final questaoDoc = await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(bancoId)
        .collection('questoes')
        .doc(questaoId)
        .get();

    if (!questaoDoc.exists) {
      return null; // Retorna null se a questão não existir
    }

    final data = questaoDoc.data();
    if (data != null) {
      data['id'] = questaoDoc.id; // Adiciona o ID da questão
      return Questao.fromMap(data); // Converte os dados para um objeto Questao
    }

    return null;
  }
}
