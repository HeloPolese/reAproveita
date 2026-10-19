import 'package:reaproveita/controller/vendedorController.dart';

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

    print('Dados validados e vendedor criado!');
    print('Nome: ${vendedor.nome}');
    print('E-mail: ${vendedor.email}');
  } catch (erro) {
    print(erro);
  }
}