import 'package:flutter/material.dart';
import 'package:reaproveita/models/produto.dart';
import '../controller/produtoController.dart';
import '../models/produto.dart';
import '../models/vendedor.dart';
import '../controller/produtoController.dart';
import 'package:reaproveita/models/produto.dart';


class CadastroProduto extends StatefulWidget {
  final Vendedor vendedor;
  final ProdutoController controller;

  const CadastroProduto({
    super.key,
    required this.vendedor,
    required this.controller,
  });

  @override
  State<CadastroProduto> createState() => _CadastroProdutoState();
}

class _CadastroProdutoState extends State<CadastroProduto> {
  final nomeController = TextEditingController();
  final validadeController = TextEditingController();
  final fabricacaoController = TextEditingController();
  final precoController = TextEditingController();
  final quantidadeController = TextEditingController();
  final descricaoController = TextEditingController();
  final imagemController = TextEditingController();
  final produtoController = ProdutoController();

  UnidadeMedida unidadeSelecionada = UnidadeMedida.unidade;

  void cadastrar() {
    try {
      final preco = double.tryParse(
        precoController.text.trim().replaceAll(',', '.'),
      );

      final quantidade = int.tryParse(
        quantidadeController.text.trim(),
      );

      if (preco == null) {
        throw Exception('Digite um preço válido, como 15,50.');
      }

      if (quantidade == null) {
        throw Exception('Digite uma quantidade inteira, como 5.');
      }

      final produto = widget.controller.cadastrar(
        vendedor: widget.vendedor,
        nome: nomeController.text,
        unidadeMedida: unidadeSelecionada,
        validade: validadeController.text,
        fabricacao: fabricacaoController.text,
        preco: preco,
        quantidadeDisponivel: quantidade,
        descricao: descricaoController.text,
        imagem: imagemController.text,
      );

      nomeController.clear();
      validadeController.clear();
      fabricacaoController.clear();
      precoController.clear();
      quantidadeController.clear();
      descricaoController.clear();
      imagemController.clear();

      // Atualiza a quantidade de produtos exibida na tela.
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produto.nome} cadastrado!'),
        ),
      );
    } catch (erro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    validadeController.dispose();
    fabricacaoController.dispose();
    precoController.dispose();
    quantidadeController.dispose();
    descricaoController.dispose();
    imagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar produto'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Vendedor: ${widget.vendedor.nome}'),
          const SizedBox(height: 16),

          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do produto',
            ),
          ),

          DropdownButtonFormField<UnidadeMedida>(
            initialValue: unidadeSelecionada,
            decoration: const InputDecoration(
              labelText: 'Unidade de medida',
            ),
            items: UnidadeMedida.values.map((unidade) {
              return DropdownMenuItem<UnidadeMedida>(
                value: unidade,
                child: Text(unidade.name),
              );
            }).toList(),
            onChanged: (valor) {
              if (valor != null) {
                setState(() {
                  unidadeSelecionada = valor;
                });
              }
            },
          ),

          TextField(
            controller: fabricacaoController,
            decoration: const InputDecoration(
              labelText: 'Data de fabricação',
              hintText: '19/10/2026',
            ),
          ),

          TextField(
            controller: validadeController,
            decoration: const InputDecoration(
              labelText: 'Data de validade',
              hintText: '22/10/2026',
            ),
          ),

          TextField(
            controller: precoController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Preço',
              prefixText: 'R\$ ',
            ),
          ),

          TextField(
            controller: quantidadeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade disponível',
            ),
          ),

          TextField(
            controller: descricaoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descrição',
            ),
          ),

          TextField(
            controller: imagemController,
            decoration: const InputDecoration(
              labelText: 'Link da imagem (opcional)',
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: cadastrar,
            child: const Text('Cadastrar produto'),
          ),

          const SizedBox(height: 16),

          Text(
            'Total de produtos na lista: '
            '${widget.controller.produtos.length}',
          ),
        ],
      ),
    );
  }
}