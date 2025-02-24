class Usuario {
  final String usuario;
  final String nome;
  final int perfil;
  final bool ativo;
  final List<String> permissoes;

  Usuario({
    required this.usuario,
    required this.nome,
    required this.perfil,
    required this.ativo,
  }) : permissoes = getPermissoes(perfil);

  static List<String> getPermissoes(int perfil) {
    return perfil == 1
        ? ["Mapa", "Perfil Usuario", "Alertas", "Lista Usuario"] // Administrador
        : ["Mapa", "Alertas"]; // Usuário
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuario: json['login'],
      nome: json['nome'],
      perfil: json['perfil'],
      ativo: json['ativo'].toString().toLowerCase() == 'true', // Converte string para booleano
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'nome': nome,
      'perfil': perfil,
      'ativo': ativo,
      'permissoes': permissoes,
    };
  }
}

// Inicializa o usuário global
late Usuario usuarioAtual;
