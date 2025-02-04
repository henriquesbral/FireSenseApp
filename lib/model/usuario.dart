class Usuario {
  final String nome;
  final String perfil;
  final String login;
  final List<String> permissoes;

  Usuario({
    required this.nome, 
    required this.perfil, 
    required this.login,
    required this.permissoes});
}

Usuario usuarioAtual = Usuario(
  nome: "João",
  perfil: "x",
  login: "Carlos.Sobral",
  permissoes: ["Mapa", "Perfil Usuario", "Alertas"], // Só pode ver a Tela A e Tela B
);