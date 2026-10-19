import 'vendedor.dart';

enum UnidadeMedida {
  unidade,
  quilo,
  grama,
  litro,
  mililitro,
}

class Produto {
  String nome;
  UnidadeMedida unidadeMedida;
  String validade;
  String fabricacao;
  double preco;
  int quantidadeDisponivel;
  String descricao;
  String imagem;
  Vendedor vendedor;
  bool adicionarAoCarrinho;

  Produto({
    required this.nome,
    required this.unidadeMedida,
    required this.validade,
    required this.fabricacao,
    required this.preco,
    required this.quantidadeDisponivel,
    required this.vendedor,
    this.descricao = '',
    this.imagem = '',
    this.adicionarAoCarrinho = false,
  });
}