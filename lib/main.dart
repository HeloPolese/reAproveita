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
        categoria: 'Padaria',
        unidadeMedida: UnidadeMedida.quilo,
        validade: '20/10/2026',
        fabricacao: '19/10/2026',
        preco: 8.50,
        quantidadeDisponivel: 10,
        descricao: 'Pão francês fresco do dia.',
        imagem: 'https://s2-receitas.glbimg.com/-V4nFrbjz9JMuWJnvQxl2NEplg8=/0x0:1280x922/924x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_e84042ef78cb4708aeebdf1c68c6cbd6/internal_photos/bs/2020/U/q/B5doHYQcKDxm0YsOynPA/pao-frances.jpeg',
        vendedor: padaria,
      ),
      Produto(
        nome: 'Banana prata',
        categoria: 'Frutas',
        unidadeMedida: UnidadeMedida.quilo,
        validade: '23/10/2026',
        fabricacao: '15/10/2026',
        preco: 5.99,
        quantidadeDisponivel: 3,
        descricao: 'Bananas maduras, ótimas para vitaminas.',
        imagem: 'https://vallefrutas.com.br/_astro/Banana-Prata-1.KqVABvKC_Zg4XYF.webp',
        vendedor: mercado,
      ),
      Produto(
        nome: 'Leite integral 1L',
        categoria: 'Laticínios',
        unidadeMedida: UnidadeMedida.unidade,
        validade: '25/10/2026',
        fabricacao: '10/10/2026',
        preco: 4.75,
        quantidadeDisponivel: 20,
        descricao: 'Leite integral próximo da validade.',
        imagem: 'https://piracanjuba-institucional-prd.s3.sa-east-1.amazonaws.com/product_images/image/leite-integral-piracanjuba-1l-frente-848x1007px-460.webp',
        vendedor: mercado,
      ),
      Produto(
        nome: 'Bolo de cenoura',
        categoria: 'Padaria',
        unidadeMedida: UnidadeMedida.unidade,
        validade: '21/10/2026',
        fabricacao: '19/10/2026',
        preco: 15.00,
        quantidadeDisponivel: 0,
        descricao: 'Bolo de cenoura com cobertura de chocolate.',
        imagem: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRRY4w8gSWQ8LeXX2hksmJpVp2WqOwzR2bQtEafCbBKlZi46IsS49qUOek&s=10',
        vendedor: padaria,
      ),
      Produto(
        nome: 'Tomate italiano',
        categoria: 'Legumes e Verduras',
        unidadeMedida: UnidadeMedida.quilo,
        validade: '24/10/2026',
        fabricacao: '17/10/2026',
        preco: 7.20,
        quantidadeDisponivel: 8,
        descricao: 'Tomates com aparência imperfeita, sabor perfeito.',
        imagem: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXHpr8M1AaKY962czdwNhWvJ5FYayJw_tlKrSFOm6e3KZ8GxzqQaocu6M&s=10',
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
