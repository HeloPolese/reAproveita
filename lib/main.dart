import 'package:flutter/material.dart';
import 'package:reaproveita/models/carrinho.dart';
import 'package:reaproveita/models/itemCarrinho.dart';
import 'package:reaproveita/models/produto.dart';
import 'package:reaproveita/models/vendedor.dart';
import 'package:reaproveita/screen/screen.carrinho.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ATENÇÃO: ajuste o construtor de Vendedor conforme a sua classe.
    final vendedor = Vendedor(nome: 'Padaria do João',pix: 'xxx',endereco: 'xxx',email: 'xxx',telefone: 'xxx', senha: 'xxx');

    final pao = Produto(
      nome: 'Pão francês (sobra do dia)',
      unidadeMedida: 'kg',
      validade: '20/10/2026',
      fabricacao: '19/10/2026',
      preco: 8.50,
      quantidadeDisponivel: 10,
      descricao: 'Pão francês fresco do dia.',
      imagem: '',
      vendedor: vendedor,
    );

    final banana = Produto(
      nome: 'Banana prata',
      unidadeMedida: 'kg',
      validade: '23/10/2026',
      fabricacao: '15/10/2026',
      preco: 5.99,
      quantidadeDisponivel: 3, // testa o limite máximo de quantidade
      descricao: 'Bananas maduras, ótimas para vitaminas.',
      imagem: 'https://picsum.photos/200',
      vendedor: vendedor,
    );

    final leite = Produto(
      nome: 'Leite integral 1L',
      unidadeMedida: 'un',
      validade: '25/10/2026',
      fabricacao: '10/10/2026',
      preco: 4.75,
      quantidadeDisponivel: 20,
      descricao: 'Leite integral próximo da validade.',
      imagem: 'https://picsum.photos/201',
      vendedor: vendedor,
    );

    final carrinho = Carrinho(listagem: [
      ItemCarrinho(produto: pao, quantidade: 2),
      ItemCarrinho(produto: banana),
      ItemCarrinho(produto: leite, quantidade: 4),
    ]);

    return MaterialApp(
      title: 'Reaproveita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: CarrinhoPage(carrinho: carrinho),
    );
  }
}