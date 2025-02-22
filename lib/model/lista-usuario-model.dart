import 'usuario.dart';

class ListaUsuarios {
  final List<Usuario> usuarios;

  ListaUsuarios({required this.usuarios});

  factory ListaUsuarios.fromJson(List<dynamic> jsonList) {
    List<Usuario> usuarios = jsonList.map((user) => Usuario.fromJson(user)).toList();
    return ListaUsuarios(usuarios: usuarios);
  }
}
