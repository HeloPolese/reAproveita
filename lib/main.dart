import 'package:flutter/material.dart';
import 'package:reaproveita/models/carrinho.dart';
import 'package:reaproveita/models/produto.dart';
import 'package:reaproveita/models/vendedor.dart';
import 'package:reaproveita/screen/screen.home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final padaria = Vendedor(
      nome: 'Padaria do João',
      pix: 'xxx',
      endereco: 'xxx',
      email: 'xxx',
      telefone: 'xxx',
      senha: 'xxx',
    );

    final mercado = Vendedor(
      nome: 'Mercado da Maria',
      pix: 'xxx',
      endereco: 'xxx',
      email: 'xxx',
      telefone: 'xxx',
      senha: 'xxx',
    );

    final produtos = <Produto>[
      Produto(
        nome: 'Pão francês (sobra do dia)',
        unidadeMedida: UnidadeMedida.quilo,
        validade: '20/10/2026',
        fabricacao: '19/10/2026',
        preco: 8.50,
        quantidadeDisponivel: 10,
        descricao: 'Pão francês fresco do dia.',
        imagem: '', // testa o placeholder de imagem
        vendedor: padaria,
      ),
      Produto(
        nome: 'Banana prata',
        unidadeMedida: UnidadeMedida.quilo,
        validade: '23/10/2026',
        fabricacao: '15/10/2026',
        preco: 5.99,
        quantidadeDisponivel: 3, // testa o limite de estoque
        descricao: 'Bananas maduras, ótimas para vitaminas.',
        imagem: 'https://picsum.photos/200',
        vendedor: mercado,
      ),
      Produto(
        nome: 'Leite integral 1L',
        unidadeMedida: UnidadeMedida.unidade,
        validade: '25/10/2026',
        fabricacao: '10/10/2026',
        preco: 4.75,
        quantidadeDisponivel: 20,
        descricao: 'Leite integral próximo da validade.',
        imagem: 'https://picsum.photos/201',
        vendedor: mercado,
      ),
      Produto(
        nome: 'Bolo de cenoura',
        unidadeMedida: UnidadeMedida.unidade,
        validade: '21/10/2026',
        fabricacao: '19/10/2026',
        preco: 15.00,
        quantidadeDisponivel: 0, // testa o estado "Indisponível"
        descricao: 'Bolo de cenoura com cobertura de chocolate.',
        imagem: 'https://picsum.photos/202',
        vendedor: padaria,
      ),
      Produto(
        nome: 'Tomate italiano',
        unidadeMedida: UnidadeMedida.quilo,
        validade: '24/10/2026',
        fabricacao: '17/10/2026',
        preco: 7.20,
        quantidadeDisponivel: 8,
        descricao: 'Tomates com aparência imperfeita, sabor perfeito.',
        imagem: 'https://picsum.photos/203',
        vendedor: mercado,
      ),
    ];

    // Carrinho começa vazio: os itens são criados pelo botão "Adicionar"
    final carrinho = Carrinho(listagem: []);

    return MaterialApp(
      title: 'Reaproveita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: HomePage(produtos: produtos, carrinho: carrinho),
    );
  }
}