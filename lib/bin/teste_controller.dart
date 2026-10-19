import 'package:reaproveita/controller/vendedorController.dart';
import 'package:reaproveita/controller/produtoController.dart';
import 'package:reaproveita/models/produto.dart';

import '../models/produto.dart';

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

    final vendedor2 = controller.cadastrar(
      nome: 'Maria',
      pix: 'maria@exemplo.com',
      endereco: 'Rua das Palmeiras, 20',
      email: 'maria@exemplo.com',
      telefone: '27988888888',
      senha: 'teste456',
    );

    final produtoController = ProdutoController();

    final produto = produtoController.cadastrar(
      vendedor: vendedor,
      nome: 'Bolo de cenoura',
      unidadeMedida: UnidadeMedida.unidade,
      validade: '22/10/2026',
      fabricacao: '19/10/2026',
      preco: 15.00,
      quantidadeDisponivel: 5,
      descricao: 'Bolo de cenoura com cobertura de chocolate.',
    );

    produtoController.cadastrar(
      vendedor: vendedor2,
      nome: 'Pão caseiro',
      unidadeMedida: UnidadeMedida.unidade,
      validade: '23/10/2026',
      fabricacao: '19/10/2026',
      preco: 10.00,
      quantidadeDisponivel: 8,
      descricao: 'Pão caseiro feito no dia.',
    );
    print('VENDEDORES:');
    
    for (final vendedor in controller.vendedores) {
      print('Nome: ${vendedor.nome}');
      print('E-mail: ${vendedor.email}');
    }
    
    print('PRODUTOS:');
    
    for (final produto in produtoController.produtos) {
      print('Nome: ${produto.nome}');
      print('Vendedor: ${produto.vendedor.nome}');
      print('Preço: R\$ ${produto.preco.toStringAsFixed(2)}');
    }

    /* print('Produto cadastrado!');
    print('Nome: ${produto.nome}');
    print('Vendedor: ${produto.vendedor.nome}');
    print('Unidade de medida: ${produto.unidadeMedida.name}');
    print('Preço: R\$ ${produto.preco.toStringAsFixed(2)}');
    print('Produtos na lista: ${produtoController.produtos.length}');
    print('Dados validados e vendedor criado!');
    print('Nome: ${vendedor.nome}');
    print('E-mail: ${vendedor.email}');*/
  } catch (erro) {
    print(erro);
  }
}
