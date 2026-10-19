import 'package:flutter/material.dart';
import 'package:reaproveita/models/produto.dart';
import 'package:reaproveita/models/vendedor.dart';
// ignore: duplicate_import
import 'package:reaproveita/models/produto.dart';

class CadastroProdutoPage extends StatefulWidget {
  final Vendedor vendedor;
  final Produto? produtoAtual;

  const CadastroProdutoPage({super.key, required this.vendedor, this.produtoAtual});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  static const verde = Color(0xFF027333);
  static const verdeEscuro = Color(0xFF027333);
  final formulario = GlobalKey<FormState>();
  bool get _editando => widget.produtoAtual != null;
  final nome = TextEditingController();
  final fabricacao = TextEditingController();
  final validade = TextEditingController();
  final preco = TextEditingController();
  final quantidade = TextEditingController();
  final descricao = TextEditingController();
  final imagem = TextEditingController();
  UnidadeMedida unidade = UnidadeMedida.unidade;

  @override
  void initState() {
    super.initState();
    final produto = widget.produtoAtual;
    if (produto != null && identical(produto.vendedor, widget.vendedor)) {
      nome.text = produto.nome;
      fabricacao.text = produto.fabricacao;
      validade.text = produto.validade;
      preco.text = produto.preco.toStringAsFixed(2).replaceAll('.', ',');
      quantidade.text = produto.quantidadeDisponivel.toString();
      descricao.text = produto.descricao;
      imagem.text = produto.imagem;
      unidade = produto.unidadeMedida;
    }
  }

  String rotulo(UnidadeMedida valor) {
    switch (valor) {
      case UnidadeMedida.unidade: return 'Unidade (un)';
      case UnidadeMedida.quilo: return 'Quilo (kg)';
      case UnidadeMedida.grama: return 'Grama (g)';
      case UnidadeMedida.litro: return 'Litro (L)';
      case UnidadeMedida.mililitro: return 'Mililitro (mL)';
    }
  }

  @override
  void dispose() {
    for (final campo in [nome, fabricacao, validade, preco, quantidade, descricao, imagem]) {
      campo.dispose();
    }
    super.dispose();
  }

  String? obrigatorio(String? valor) {
    return valor == null || valor.trim().isEmpty ? 'Preencha este campo.' : null;
  }

  // Confere o formato e rejeita datas inexistentes, como 31/02/2026.
  DateTime? lerData(String texto) {
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(texto.trim())) return null;
    final partes = texto.trim().split('/').map(int.parse).toList();
    if (partes[2] < 1900 || partes[2] > 2200) return null;
    final data = DateTime(partes[2], partes[1], partes[0]);
    if (data.day != partes[0] || data.month != partes[1] || data.year != partes[2]) {
      return null;
    }
    return data;
  }

  Future<void> selecionarData(TextEditingController campo) async {
    FocusScope.of(context).unfocus();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: lerData(campo.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200, 12, 31),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (escolhida == null || !mounted) return;
    campo.text = '${escolhida.day.toString().padLeft(2, '0')}/'
        '${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}';
  }

  void cadastrar() {
    if (!formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final existente = widget.produtoAtual;
    if (existente != null && !identical(existente.vendedor, widget.vendedor)) return;

    final valor = double.parse(preco.text.trim().replaceAll(',', '.'));
    final estoque = int.parse(quantidade.text.trim());
    final produto = existente ?? Produto(
      nome: nome.text.trim(),
      unidadeMedida: unidade,
      validade: validade.text.trim(),
      categoria: 'Frutas',
      fabricacao: fabricacao.text.trim(),
      preco: valor,
      quantidadeDisponivel: estoque,
      descricao: descricao.text.trim(),
      imagem: imagem.text.trim(),
      vendedor: widget.vendedor,
    );
    if (existente != null) {
      // Só altera o objeto original ao salvar. Cancelar não muda o produto.
      existente.nome = nome.text.trim();
      existente.unidadeMedida = unidade;
      existente.validade = validade.text.trim();
      existente.fabricacao = fabricacao.text.trim();
      existente.preco = valor;
      existente.quantidadeDisponivel = estoque;
      existente.descricao = descricao.text.trim();
      existente.imagem = imagem.text.trim();
    }
    // A Home recebe o produto e o adiciona à lista compartilhada.
    Navigator.pop(context, produto);
  }

  // Mesmo estilo para todos os campos, sem repetir a decoração.
  Widget campo({
    required String titulo,
    required String dica,
    required TextEditingController controller,
    required IconData icone,
    TextInputType teclado = TextInputType.text,
    String? Function(String?)? validar,
    int linhas = 1,
    Widget? botao,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(
          color: verdeEscuro, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: teclado,
          maxLines: linhas,
          validator: validar ?? obrigatorio,
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(color: Color(0xFF758276), fontSize: 14),
            prefixIcon: Icon(icone, color: verde, size: 20),
            suffixIcon: botao,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x8066A638)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x8066A638)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: verde, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Duas colunas no computador e uma coluna nas telas menores.
  Widget colunas(List<Widget> campos) {
    return LayoutBuilder(builder: (context, limites) {
      final largura = limites.maxWidth >= 640
          ? (limites.maxWidth - 24) / 2
          : limites.maxWidth;
      return Wrap(
        spacing: 24,
        runSpacing: 22,
        children: campos.map((item) => SizedBox(width: largura, child: item)).toList(),
      );
    });
  }

  Widget secao(String titulo, String descricao, Widget conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(
            color: verde, fontSize: 23, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 7),
          Container(width: 48, height: 3, color: const Color(0xFF63BF21)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4066A638)),
              boxShadow: const [BoxShadow(
                color: Color(0x0C027333), blurRadius: 16, offset: Offset(0, 5),
              )],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(descricao, style: const TextStyle(
                  color: Color(0xFF627064), height: 1.5,
                )),
                const SizedBox(height: 22),
                conteudo,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.produtoAtual != null &&
        !identical(widget.produtoAtual!.vendedor, widget.vendedor)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produto')),
        body: const Center(child: Text('Você só pode editar seus próprios produtos.')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 76,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF2E857),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(9),
                child: Icon(Icons.eco_outlined, color: verde, size: 31),
              ),
            ),
            SizedBox(width: 10),
            Text('Reaproveita', style: TextStyle(
              color: verdeEscuro, fontWeight: FontWeight.bold, fontSize: 23,
            )),
          ],
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0x4066A638)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Form(
                key: formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text('ESPAÇO DO VENDEDOR', style: TextStyle(
                      color: verde, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, fontSize: 11,
                    )),
                    const SizedBox(height: 10),
                    Text(_editando ? 'Edite seu produto.' : 'Cadastre seu produto.', style: const TextStyle(
                      color: verde, fontSize: 32, fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 10),
                    const Text('Preencha as informações do produto que deseja oferecer.',
                      style: TextStyle(color: Color(0xFF627064), fontSize: 16, height: 1.5)),
                    ...[
                      const SizedBox(height: 12),
                      Text('Vendedor: ${widget.vendedor.nome}',
                        style: const TextStyle(color: verde, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 30),
                    secao('Informações do produto', 'Identifique seu produto e escolha como ele será vendido.',
                      Column(children: [
                        colunas([
                          campo(titulo: 'Nome do produto', dica: 'Ex.: Bolo de cenoura',
                            controller: nome, icone: Icons.inventory_2_outlined),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Unidade de medida', style: TextStyle(
                              color: verde, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<UnidadeMedida>(
                              key: ValueKey(unidade),
                              initialValue: unidade,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.straighten, color: verde, size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF2F2F2),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0x8066A638))),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: verde, width: 2)),
                              ),
                              items: UnidadeMedida.values.map((opcao) => DropdownMenuItem(
                                value: opcao, child: Text(rotulo(opcao)),
                              )).toList(),
                              onChanged: (valor) {
                                if (valor != null) setState(() => unidade = valor);
                              },
                            ),
                          ]),
                        ]),
                        const SizedBox(height: 22),
                        campo(titulo: 'Descrição (opcional)', dica: 'Descreva os ingredientes, características ou cuidados do produto.',
                          controller: descricao, icone: Icons.notes_outlined, linhas: 3,
                          validar: (_) => null),
                      ]),
                    ),
                    secao('Preço e disponibilidade', 'Informe o preço por unidade de medida e a quantidade disponível.',
                      colunas([
                        campo(titulo: 'Preço (R\$)', dica: 'Ex.: 15,50 — sem separador de milhar',
                          controller: preco, icone: Icons.payments_outlined,
                          teclado: const TextInputType.numberWithOptions(decimal: true),
                          validar: (valor) {
                            final texto = valor?.trim() ?? '';
                            if (!RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(texto)) {
                              return 'Informe um preço com até 2 casas decimais.';
                            }
                            final numero = double.tryParse(texto.replaceAll(',', '.'));
                            if (numero == null || !numero.isFinite || numero <= 0) {
                              return 'O preço deve ser maior que zero.';
                            }
                            return null;
                          }),
                        campo(titulo: 'Quantidade disponível', dica: 'Ex.: 5 (quantidade inteira)',
                          controller: quantidade, icone: Icons.numbers,
                          teclado: TextInputType.number, validar: (valor) {
                            final numero = int.tryParse(valor?.trim() ?? '');
                            if (numero == null || numero < 0 || (!_editando && numero == 0)) {
                              return _editando ? 'Informe uma quantidade inteira a partir de zero.'
                                  : 'Informe uma quantidade inteira maior que zero.';
                            }
                            return null;
                          }),
                      ]),
                    ),
                    secao('Fabricação e validade', 'Digite as datas no formato dia/mês/ano ou use o calendário.',
                      colunas([
                        campo(titulo: 'Data de fabricação', dica: 'DD/MM/AAAA',
                          controller: fabricacao, icone: Icons.event_outlined,
                          teclado: TextInputType.datetime,
                          validar: (valor) => lerData(valor ?? '') == null ? 'Informe uma data válida: DD/MM/AAAA.' : null,
                          botao: IconButton(
                            tooltip: 'Escolher data de fabricação',
                            onPressed: () => selecionarData(fabricacao),
                            icon: const Icon(Icons.calendar_month_outlined, color: verde))),
                        campo(titulo: 'Data de validade', dica: 'DD/MM/AAAA',
                          controller: validade, icone: Icons.event_available_outlined,
                          teclado: TextInputType.datetime, validar: (valor) {
                            final data = lerData(valor ?? '');
                            if (data == null) return 'Informe uma data válida: DD/MM/AAAA.';
                            final inicio = lerData(fabricacao.text);
                            if (inicio != null && data.isBefore(inicio)) {
                              return 'A validade não pode ser anterior à fabricação.';
                            }
                            return null;
                          },
                          botao: IconButton(
                            tooltip: 'Escolher data de validade',
                            onPressed: () => selecionarData(validade),
                            icon: const Icon(Icons.calendar_month_outlined, color: verde))),
                      ]),
                    ),
                    secao('Imagem do produto', 'Opcional: informe o link de uma imagem. Você pode cadastrar sem preencher.',
                      campo(titulo: 'Link da imagem', dica: 'https://exemplo.com/produto.jpg',
                        controller: imagem, icone: Icons.image_outlined,
                        teclado: TextInputType.url, validar: (valor) {
                          final texto = valor?.trim() ?? '';
                          if (texto.isEmpty) return null;
                          final url = Uri.tryParse(texto);
                          if (url == null || (url.scheme != 'https' && url.scheme != 'http') || url.host.isEmpty) {
                            return 'Informe um link começando com https:// ou http://.';
                          }
                          return null;
                        }),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 300,
                        child: ElevatedButton.icon(
                          onPressed: cadastrar,
                          icon: Icon(_editando ? Icons.save_outlined : Icons.add_circle_outline),
                          label: Text(_editando ? 'Salvar alterações' : 'Cadastrar produto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verde,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 56),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    if (_editando)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar edição'),
                        ),
                      ),
                    const SizedBox(height: 22),
                    const Text('Demonstração: os produtos ficam disponíveis na Home durante esta sessão.',
                      style: TextStyle(color: Color(0xFF627064), fontSize: 12, height: 1.5)),
                    const SizedBox(height: 30),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
