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

    final produtos = [
      Produto(
        nome: 'Banana',
        categoria: 'Frutas',
        unidadeMedida: 'kg',
        validade: '30/10/2026',
        fabricacao: '19/10/2026',
        preco: 3.50,
        quantidadeDisponivel: 20,
        descricao: 'Bananas frescas para consumo.',
        imagem: '',
        vendedor: mercado,
      ),
      Produto(
        nome: 'Maçã',
        categoria: 'Frutas',
        unidadeMedida: 'kg',
        validade: '05/11/2026',
        fabricacao: '18/10/2026',
        preco: 5.90,
        quantidadeDisponivel: 15,
        descricao: 'Maçãs selecionadas.',
        imagem: '',
        vendedor: mercado,
      ),
      Produto(
        nome: 'Pão artesanal',
        categoria: 'Padaria',
        unidadeMedida: 'unidade',
        validade: '21/10/2026',
        fabricacao: '19/10/2026',
        preco: 4.00,
        quantidadeDisponivel: 10,
        descricao: 'Pão artesanal feito no dia.',
        imagem: '',
        vendedor: padaria,
      ),
      Produto(
        nome: 'Bolo de chocolate',
        categoria: 'Padaria',
        unidadeMedida: 'unidade',
        validade: '22/10/2026',
        fabricacao: '19/10/2026',
        preco: 15.00,
        quantidadeDisponivel: 5,
        descricao: 'Bolo de chocolate caseiro.',
        imagem: '',
        vendedor: padaria,
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