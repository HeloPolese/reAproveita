import 'package:flutter/material.dart';

// Para testar este arquivo sem alterar seu main.dart:
// flutter run -d chrome -t lib/screen/screen.cadastrarProduto.dart
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reaproveita | Produtos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF027333))
            .copyWith(
              primary: const Color(0xFF027333),
              secondary: const Color(0xFF63BF21),
              tertiary: const Color(0xFF66A638),
              surface: const Color(0xFFF2F2F2),
            ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      ),
      home: const CadastroProdutoScreen(),
    ),
  );
}

// Enum privado desta tela: não depende do enum do seu model.
enum _UnidadeMedida { unidade, quilo, grama, litro, mililitro, penca }

class CadastroProdutoScreen extends StatefulWidget {
  // Ao integrar as telas, passe aqui o nome do vendedor cadastrado.
  final String? nomeVendedor;

  const CadastroProdutoScreen({super.key, this.nomeVendedor});

  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  static const verde = Color(0xFF027333);
  static const verdeEscuro = Color(0xFF027333);
  final formulario = GlobalKey<FormState>();
  final nome = TextEditingController();
  final fabricacao = TextEditingController();
  final validade = TextEditingController();
  final preco = TextEditingController();
  final quantidade = TextEditingController();
  final descricao = TextEditingController();
  final imagem = TextEditingController();
  _UnidadeMedida unidade = _UnidadeMedida.unidade;

  // Lista em memória: não publica produtos em um servidor.
  final List<Map<String, Object?>> produtos = [];

  String rotulo(_UnidadeMedida valor) {
    switch (valor) {
      case _UnidadeMedida.unidade:
        return 'Unidade (un)';
      case _UnidadeMedida.quilo:
        return 'Quilo (kg)';
      case _UnidadeMedida.grama:
        return 'Grama (g)';
      case _UnidadeMedida.litro:
        return 'Litro (L)';
      case _UnidadeMedida.mililitro:
        return 'Mililitro (mL)';
      case _UnidadeMedida.penca:
        return 'Penca';
    }
  }

  @override
  void dispose() {
    for (final campo in [
      nome,
      fabricacao,
      validade,
      preco,
      quantidade,
      descricao,
      imagem,
    ]) {
      campo.dispose();
    }
    super.dispose();
  }

  String? obrigatorio(String? valor) {
    return valor == null || valor.trim().isEmpty
        ? 'Preencha este campo.'
        : null;
  }

  // Confere o formato e rejeita datas inexistentes, como 31/02/2026.
  DateTime? lerData(String texto) {
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(texto.trim())) return null;
    final partes = texto.trim().split('/').map(int.parse).toList();
    if (partes[2] < 1900 || partes[2] > 2200) return null;
    final data = DateTime(partes[2], partes[1], partes[0]);
    if (data.day != partes[0] ||
        data.month != partes[1] ||
        data.year != partes[2]) {
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
    campo.text =
        '${escolhida.day.toString().padLeft(2, '0')}/'
        '${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}';
  }

  void cadastrar() {
    if (!formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final nomeCadastrado = nome.text.trim();
    setState(() {
      produtos.add({
        'nome': nomeCadastrado,
        'unidadeMedida': unidade,
        'fabricacao': fabricacao.text.trim(),
        'validade': validade.text.trim(),
        'preco': double.parse(preco.text.trim().replaceAll(',', '.')),
        'quantidadeDisponivel': int.parse(quantidade.text.trim()),
        'descricao': descricao.text.trim(),
        'imagem': imagem.text.trim(),
        'vendedor': widget.nomeVendedor,
      });
    });
    formulario.currentState!.reset();
    for (final campo in [
      nome,
      fabricacao,
      validade,
      preco,
      quantidade,
      descricao,
      imagem,
    ]) {
      campo.clear();
    }
    setState(() => unidade = _UnidadeMedida.unidade);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: verde,
        content: Text('$nomeCadastrado foi adicionado à lista.'),
      ),
    );
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
        Text(
          titulo,
          style: const TextStyle(
            color: verdeEscuro,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
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
    return LayoutBuilder(
      builder: (context, limites) {
        final largura = limites.maxWidth >= 640
            ? (limites.maxWidth - 24) / 2
            : limites.maxWidth;
        return Wrap(
          spacing: 24,
          runSpacing: 22,
          children: campos
              .map((item) => SizedBox(width: largura, child: item))
              .toList(),
        );
      },
    );
  }

  Widget secao(String titulo, String descricao, Widget conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: verde,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
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
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C027333),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  descricao,
                  style: const TextStyle(color: Color(0xFF627064), height: 1.5),
                ),
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
            Text(
              'Reaproveita',
              style: TextStyle(
                color: verdeEscuro,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
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
                    const Text(
                      'ESPAÇO DO VENDEDOR',
                      style: TextStyle(
                        color: verde,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cadastre seu produto.',
                      style: TextStyle(
                        color: verde,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Preencha as informações do produto que deseja oferecer.',
                      style: TextStyle(
                        color: Color(0xFF627064),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    if (widget.nomeVendedor != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Vendedor: ${widget.nomeVendedor}',
                        style: const TextStyle(
                          color: verde,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    secao(
                      'Informações do produto',
                      'Identifique seu produto e escolha como ele será vendido.',
                      Column(
                        children: [
                          colunas([
                            campo(
                              titulo: 'Nome do produto',
                              dica: 'Ex.: Bolo de cenoura',
                              controller: nome,
                              icone: Icons.inventory_2_outlined,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Unidade de medida',
                                  style: TextStyle(
                                    color: verde,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<_UnidadeMedida>(
                                  initialValue: _UnidadeMedida.unidade,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.straighten,
                                      color: verde,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F2),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0x8066A638),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: verde,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  items: _UnidadeMedida.values
                                      .map(
                                        (opcao) => DropdownMenuItem(
                                          value: opcao,
                                          child: Text(rotulo(opcao)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (valor) {
                                    if (valor != null)
                                      setState(() => unidade = valor);
                                  },
                                ),
                              ],
                            ),
                          ]),
                          const SizedBox(height: 22),
                          campo(
                            titulo: 'Descrição (opcional)',
                            dica: 'Descreva os ingredientes, características ou cuidados do produto.',
                            controller: descricao,
                            icone: Icons.notes_outlined,
                            linhas: 3,
                            validar: (_) => null,
                          ),
                        ],
                      ),
                    ),
                    secao(
                      'Preço e disponibilidade',
                      'Informe o preço por unidade de medida e a quantidade disponível.',
                      colunas([
                        campo(
                          titulo: 'Preço (R\$)',
                          dica: 'Ex.: 15,50 — sem separador de milhar',
                          controller: preco,
                          icone: Icons.payments_outlined,
                          teclado: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validar: (valor) {
                            final texto = valor?.trim() ?? '';
                            if (!RegExp(r'^\d+([.,]\d{1,2})?$')
                                .hasMatch(texto)) {
                              return 'Informe um preço com até 2 casas decimais.';
                            }
                            final numero = double.tryParse(
                              texto.replaceAll(',', '.'),
                            );
                            if (numero == null ||
                                !numero.isFinite ||
                                numero <= 0) {
                              return 'O preço deve ser maior que zero.';
                            }
                            return null;
                          },
                        ),
                        campo(
                          titulo: 'Quantidade disponível',
                          dica: 'Ex.: 5 (quantidade inteira)',
                          controller: quantidade,
                          icone: Icons.numbers,
                          teclado: TextInputType.number,
                          validar: (valor) {
                            final numero = int.tryParse(valor?.trim() ?? '');
                            return numero == null || numero <= 0
                                ? 'Informe uma quantidade inteira maior que zero.'
                                : null;
                          },
                        ),
                      ]),
                    ),
                    secao(
                      'Fabricação e validade',
                      'Digite as datas no formato dia/mês/ano ou use o calendário.',
                      colunas([
                        campo(
                          titulo: 'Data de fabricação',
                          dica: 'DD/MM/AAAA',
                          controller: fabricacao,
                          icone: Icons.event_outlined,
                          teclado: TextInputType.datetime,
                          validar: (valor) => lerData(valor ?? '') == null
                              ? 'Informe uma data válida: DD/MM/AAAA.'
                              : null,
                          botao: IconButton(
                            tooltip: 'Escolher data de fabricação',
                            onPressed: () => selecionarData(fabricacao),
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              color: verde,
                            ),
                          ),
                        ),
                        campo(
                          titulo: 'Data de validade',
                          dica: 'DD/MM/AAAA',
                          controller: validade,
                          icone: Icons.event_available_outlined,
                          teclado: TextInputType.datetime,
                          validar: (valor) {
                            final data = lerData(valor ?? '');
                            if (data == null)
                              return 'Informe uma data válida: DD/MM/AAAA.';
                            final inicio = lerData(fabricacao.text);
                            if (inicio != null && data.isBefore(inicio)) {
                              return 'A validade não pode ser anterior à fabricação.';
                            }
                            return null;
                          },
                          botao: IconButton(
                            tooltip: 'Escolher data de validade',
                            onPressed: () => selecionarData(validade),
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              color: verde,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    secao(
                      'Imagem do produto',
                      'Opcional: informe o link de uma imagem. Você pode cadastrar sem preencher.',
                      campo(
                        titulo: 'Link da imagem',
                        dica: 'https://exemplo.com/produto.jpg',
                        controller: imagem,
                        icone: Icons.image_outlined,
                        teclado: TextInputType.url,
                        validar: (valor) {
                          final texto = valor?.trim() ?? '';
                          if (texto.isEmpty) return null;
                          final url = Uri.tryParse(texto);
                          if (url == null ||
                              (url.scheme != 'https' && url.scheme != 'http') ||
                              url.host.isEmpty) {
                            return 'Informe um link começando com https:// ou http://.';
                          }
                          return null;
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 300,
                        child: ElevatedButton.icon(
                          onPressed: cadastrar,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Cadastrar produto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verde,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 56),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Demonstração: os produtos ficam na memória desta tela e não são publicados.',
                      style: TextStyle(
                        color: Color(0xFF627064),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (produtos.isNotEmpty)
                      secao(
                        'Produtos cadastrados',
                        '${produtos.length} produto(s) nesta sessão.',
                        Column(
                          children: produtos.map((produto) {
                            final valor = produto['preco'] as double;
                            final unidadeProduto =
                                produto['unidadeMedida'] as _UnidadeMedida;
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produto['nome'] as String,
                                    style: const TextStyle(
                                      color: verde,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} / ${rotulo(unidadeProduto)}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Quantidade: ${produto['quantidadeDisponivel']} • Validade: ${produto['validade']}',
                                  ),
                                  if (produto['vendedor'] != null)
                                    Text('Vendedor: ${produto['vendedor']}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
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
