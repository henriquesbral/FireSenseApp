class Usuario {
  final String nome;
  final int codPerfil;
  final String login;
  final bool ativo;
  final String token;
  final List<String> permissoes;

  Usuario({
    required this.nome,
    required this.codPerfil,
    required this.login,
    required this.ativo,
    required this.token,
  }) : permissoes = getPermissoes(codPerfil);

  // Define permissões com base no código do perfil
  static List<String> getPermissoes(int codPerfil) {
    if (codPerfil == 1) {
      return ["Mapa", "Perfil Usuario", "Alertas", "Lista Usuario"]; // Administrador
    } else if (codPerfil == 2) {
      return ["Mapa", "Alertas"]; // Usuário
    }
    return []; // Sem permissões caso o perfil não seja reconhecido
  }

  // Construtor para criar um objeto a partir de um JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nome: json['nome'],
      codPerfil: json['codPerfil'],
      login: json['usuario'], // A API retorna 'usuario' como login
      ativo: json['ativo'],
      token: json['token'],
    );
  }

  // Método para converter o objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'codPerfil': codPerfil,
      'login': login,
      'ativo': ativo,
      'token': token,
      'permissoes': permissoes,
    };
  }
}

// Inicialização vazia para evitar erro antes do login
late Usuario usuarioAtual;
