class Usuario {
  final String nome;
  final int codPerfil;
  final String login;
  final bool ativo;
  final List<String> permissoes;

  Usuario({
    required this.nome,
    required this.codPerfil,
    required this.login,
    required this.ativo,
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
      login: json['login'],
      ativo: json['ativo']
    );
  }

  // Método para converter o objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'codPerfil': codPerfil,
      'login': login,
      'ativo': ativo,
      'permissoes': permissoes,
    };
  }
}

// Exemplo de inicialização do usuário
Usuario usuarioAtual = Usuario(
  nome: "João",
  codPerfil: 1, // Administrador
  login: "Carlos.Sobral",
  ativo: true
);
