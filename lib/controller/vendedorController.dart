import '../models/Vendedor.dart';

class VendedorController {
  Vendedor cadastrar({
    required String nome,
    required String pix,
    required String endereco,
    required String email,
    required String telefone,
    required String senha,
  }) {
    if (nome.trim().isEmpty ||
        pix.trim().isEmpty ||
        endereco.trim().isEmpty ||
        email.trim().isEmpty ||
        telefone.trim().isEmpty ||
        senha.isEmpty) {
      throw Exception('Preencha todos os campos.');
    }

    // Regra inicial de exemplo; ajustem conforme o projeto.
    if (senha.length < 8) {
      throw Exception('A senha deve ter pelo menos 8 caracteres.');
    }

    final vendedor = Vendedor(
      nome: nome.trim(),
      pix: pix.trim(),
      endereco: endereco.trim(),
      email: email.trim(),
      telefone: telefone.trim(),
      senha: senha,
    );
    return vendedor;
  }
}
