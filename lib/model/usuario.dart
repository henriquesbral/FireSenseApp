class Usuario {
  final String nome;
  final String perfil;
  final List<String> permissoes;

  Usuario({
    required this.nome, 
    required this.perfil, 
    required this.permissoes});
}

Usuario usuarioAtual = Usuario(
  nome: "João",
  perfil: "x",
  permissoes: ["Mapa", "Alertas"], // Só pode ver a Tela A e Tela B
);