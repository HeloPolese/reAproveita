import 'package:reaproveita/controller/vendedorController.dart';
import 'package:reaproveita/controller/produtoController.dart';

void main() {

  final controller = VendedorController();

  try {

    final vendedor = controller.cadastrar(
      nome: 'Vitor',
      pix: 'vitor@exemplo.com',
      endereco: 'Rua das Flores, 10',
      email: 'vitor@exemplo.com',
      telefone: '27999999999',
      senha: 'teste123',
    );

    final produtoController = ProdutoController();

    final produto = produtoController.cadastrar(
      vendedor: vendedor,
      nome: 'Bolo de cenoura',
      unidadeMedida: 'Unidade',
      validade: '22/10/2026',
      fabricacao: '19/10/2026',
      preco: 15.00,
      quantidadeDisponivel: 5,
      descricao: 'Bolo de cenoura com cobertura de chocolate.',
    );

    print('Produto cadastrado!');
    print('Nome: ${produto.nome}');
    print('Vendedor: ${produto.vendedor.nome}');
    print('Preço: R\$ ${produto.preco.toStringAsFixed(2)}');
    print('Produtos na lista: ${produtoController.produtos.length}');
    print('Dados validados e vendedor criado!');
    print('Nome: ${vendedor.nome}');
    print('E-mail: ${vendedor.email}');
  } catch (erro) {
    print(erro);
  }
}
