import 'package:flutter/material.dart';
import 'package:reaproveita/models/vendedor.dart';

class CadastroPage extends StatefulWidget {
  // Sem vendedor: cria um cadastro. Com vendedor: edita o perfil.
  final Vendedor? vendedorAtual;

  const CadastroPage({super.key, this.vendedorAtual});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  static const _verde = Color(0xFF027333);
  static const _verdeClaro = Color(0xFFE8F5E9);
  static const _fundo = Color(0xFFF2F2F2);
  static const _texto = Color(0xFF1F2937);
  static const _textoSecundario = Color(0xFF6B7280);
  static const _borda = Color(0xFFE5E7EB);
  static const _erro = Color(0xFFD32F2F);
  static const _sombra = Color(0x14000000);
  static const _gradiente = LinearGradient(
    colors: [Color(0xFF027333), Color(0xFF66A638)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _pix = TextEditingController();
  final _endereco = TextEditingController();
  final _senha = TextEditingController();
  final _confirmarSenha = TextEditingController();

  bool _ocultarSenha = true;
  bool _ocultarConfirmacao = true;
  bool _salvando = false;

  bool get _editando => widget.vendedorAtual != null;

  @override
  void initState() {
    super.initState();

    final vendedor = widget.vendedorAtual;
    if (vendedor != null) {
      _nome.text = vendedor.nome;
      _telefone.text = vendedor.telefone;
      _email.text = vendedor.email;
      _pix.text = vendedor.pix;
      _endereco.text = vendedor.endereco;
      // Não mostra a senha atual. Em edição, vazio mantém a senha existente.
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nome,
      _telefone,
      _email,
      _pix,
      _endereco,
      _senha,
      _confirmarSenha,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _obrigatorio(String? valor) {
    return valor == null || valor.trim().isEmpty
        ? 'Preencha este campo.'
        : null;
  }

  String? _validarTelefone(String? valor) {
    final vazio = _obrigatorio(valor);
    if (vazio != null) return vazio;

    final digitos = valor!.replaceAll(RegExp(r'\D'), '');
    return digitos.length == 10 || digitos.length == 11
        ? null
        : 'Informe o telefone com DDD (10 ou 11 dígitos).';
  }

  String? _validarEmail(String? valor) {
    final texto = valor?.trim() ?? '';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(texto)
        ? null
        : 'Digite um e-mail válido.';
  }

  String? _validarSenha(String? valor) {
    if (_editando && (valor == null || valor.isEmpty)) return null;

    if (valor == null || valor.trim().isEmpty || valor.length < 8) {
      return 'Use pelo menos 8 caracteres.';
    }
    return null;
  }

  String? _validarConfirmacao(String? valor) {
    if (_editando && _senha.text.isEmpty) {
      return valor == null || valor.isEmpty
          ? null
          : 'Informe a nova senha primeiro.';
    }

    if (valor == null || valor.isEmpty) return 'Confirme sua senha.';
    return valor == _senha.text ? null : 'As senhas precisam ser iguais.';
  }

  Future<void> _cadastrar() async {
    if (_salvando || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    final vendedor = widget.vendedorAtual ??
        Vendedor(
          nome: _nome.text.trim(),
          pix: _pix.text.trim(),
          endereco: _endereco.text.trim(),
          email: _email.text.trim().toLowerCase(),
          telefone: _telefone.text.trim(),
          senha: _senha.text,
        );

    if (_editando) {
      // Mantém o mesmo objeto: os produtos continuam ligados a este vendedor.
      vendedor.nome = _nome.text.trim();
      vendedor.pix = _pix.text.trim();
      vendedor.endereco = _endereco.text.trim();
      vendedor.email = _email.text.trim().toLowerCase();
      vendedor.telefone = _telefone.text.trim();

      if (_senha.text.isNotEmpty) {
        vendedor.senha = _senha.text;
      }
    }

    // Protótipo em memória. Não há API de autenticação nem persistência.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: _verdeClaro,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: _verde,
                size: 52,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _editando ? 'Dados atualizados!' : 'Cadastro realizado!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _texto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _editando
                  ? 'Suas alterações foram salvas nesta sessão.'
                  : 'Bem-vindo(a), ${vendedor.nome}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: _textoSecundario,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _verde,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Concluir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    // Este retorno permite que a Home guarde o usuário conectado.
    Navigator.pop(context, vendedor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: _gradiente),
        ),
        centerTitle: true,
        title: Text(
          _editando ? 'Meu perfil' : 'Criar conta',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editando
                          ? 'SEUS DADOS'
                          : 'FAÇA PARTE DA COMUNIDADE',
                      style: const TextStyle(
                        color: _verde,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _editando
                          ? 'Edite seu perfil'
                          : 'Seu cadastro começa aqui',
                      style: const TextStyle(
                        color: _texto,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _editando
                          ? 'Atualize suas informações e salve as alterações.'
                          : 'Preencha seus dados para participar do Reaproveita.',
                      style: const TextStyle(
                        color: _textoSecundario,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _secao(
                      icone: Icons.person_outline,
                      titulo: 'Informações pessoais',
                      descricao:
                          'Todos os campos desta seção são obrigatórios.',
                      conteudo: _colunas([
                        _campo(
                          titulo: 'Nome completo',
                          dica: 'Digite seu nome',
                          controller: _nome,
                          icone: Icons.person_outline,
                          validar: _obrigatorio,
                          capitalizacao: TextCapitalization.words,
                        ),
                        _campo(
                          titulo: 'Telefone',
                          dica: '(27) 99999-9999',
                          controller: _telefone,
                          icone: Icons.phone_outlined,
                          teclado: TextInputType.phone,
                          validar: _validarTelefone,
                        ),
                        _campo(
                          titulo: 'E-mail',
                          dica: 'voce@exemplo.com',
                          controller: _email,
                          icone: Icons.mail_outline,
                          teclado: TextInputType.emailAddress,
                          validar: _validarEmail,
                        ),
                        _campo(
                          titulo: 'Chave Pix',
                          dica: 'CPF, e-mail, telefone ou chave aleatória',
                          controller: _pix,
                          icone: Icons.pix,
                          validar: _obrigatorio,
                        ),
                      ]),
                    ),
                    _secao(
                      icone: Icons.location_on_outlined,
                      titulo: 'Endereço',
                      descricao:
                          'Informe o endereço que deseja usar no cadastro.',
                      conteudo: _campo(
                        titulo: 'Endereço completo',
                        dica: 'Rua, número, bairro, cidade e estado',
                        controller: _endereco,
                        icone: Icons.location_on_outlined,
                        teclado: TextInputType.streetAddress,
                        validar: _obrigatorio,
                        capitalizacao: TextCapitalization.words,
                      ),
                    ),
                    _secao(
                      icone: Icons.lock_outline,
                      titulo: 'Senha de acesso',
                      descricao: _editando
                          ? 'Deixe os dois campos vazios para manter a senha atual.'
                          : 'Sua senha deve conter:\n'
                              '• Pelo menos 8 caracteres\n'
                              '• Uma letra maiúscula\n'
                              '• Uma letra minúscula\n'
                              '• Pelo menos um número\n'
                              '• Um caractere especial, como ".", "?", "!", "@" ou "#".',
                      conteudo: _colunas([
                        _campo(
                          titulo:
                              _editando ? 'Nova senha (opcional)' : 'Senha',
                          dica: 'Pelo menos 8 caracteres',
                          controller: _senha,
                          icone: Icons.lock_outline,
                          ocultar: _ocultarSenha,
                          validar: _validarSenha,
                          botao: IconButton(
                            tooltip: _ocultarSenha
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                            onPressed: () => setState(
                              () => _ocultarSenha = !_ocultarSenha,
                            ),
                            icon: Icon(
                              _ocultarSenha
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _textoSecundario,
                            ),
                          ),
                        ),
                        _campo(
                          titulo: 'Confirmar senha',
                          dica: 'Digite a senha novamente',
                          controller: _confirmarSenha,
                          icone: Icons.lock_outline,
                          ocultar: _ocultarConfirmacao,
                          validar: _validarConfirmacao,
                          botao: IconButton(
                            tooltip: _ocultarConfirmacao
                                ? 'Mostrar confirmação'
                                : 'Ocultar confirmação',
                            onPressed: () => setState(
                              () => _ocultarConfirmacao =
                                  !_ocultarConfirmacao,
                            ),
                            icon: Icon(
                              _ocultarConfirmacao
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _textoSecundario,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _verde,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _salvando ? null : _cadastrar,
                        icon: Icon(
                          _editando
                              ? Icons.save_outlined
                              : Icons.person_add_alt_1_outlined,
                        ),
                        label: Text(
                          _editando ? 'Salvar alterações' : 'Criar conta',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required String titulo,
    required String dica,
    required TextEditingController controller,
    required IconData icone,
    required String? Function(String?) validar,
    TextInputType teclado = TextInputType.text,
    TextCapitalization capitalizacao = TextCapitalization.none,
    bool ocultar = false,
    Widget? botao,
  }) {
    OutlineInputBorder borda(Color cor, [double largura = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: _texto,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: teclado,
          textCapitalization: capitalizacao,
          obscureText: ocultar,
          validator: validar,
          style: const TextStyle(color: _texto, fontSize: 15),
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(
              color: _textoSecundario,
              fontSize: 14,
            ),
            prefixIcon: Icon(icone, color: _verde, size: 20),
            suffixIcon: botao,
            filled: true,
            fillColor: _fundo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: borda(_borda),
            enabledBorder: borda(_borda),
            focusedBorder: borda(_verde, 2),
            errorBorder: borda(_erro),
            focusedErrorBorder: borda(_erro, 2),
          ),
        ),
      ],
    );
  }

  Widget _colunas(List<Widget> campos) {
    return LayoutBuilder(
      builder: (context, limites) {
        final largura = limites.maxWidth >= 600
            ? (limites.maxWidth - 20) / 2
            : limites.maxWidth;

        return Wrap(
          spacing: 20,
          runSpacing: 18,
          children: campos
              .map((campo) => SizedBox(width: largura, child: campo))
              .toList(),
        );
      },
    );
  }

  Widget _secao({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Widget conteudo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: _sombra,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _verdeClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, color: _verde, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: _texto,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              descricao,
              style: const TextStyle(
                color: _textoSecundario,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            conteudo,
          ],
        ),
      ),
    );
  }
}