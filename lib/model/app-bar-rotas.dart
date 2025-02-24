import 'package:aps/pages/perfil-usuario.dart';
import 'package:flutter/material.dart';
import 'usuario.dart';
import 'package:aps/pages/mapa-dashboard.dart';
import 'package:aps/pages/mapa-alertas.dart';
import 'package:aps/pages/cadastro.dart';
import 'package:aps/pages/lista-usuarios.dart';
import 'package:aps/pages/login.dart'; // Importação da tela de login
import 'package:aps/services/storage_service.dart'; // Para limpar o token

class MenuAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Usuario usuario;
  final String tituloInicial;

  MenuAppBar({required this.usuario, this.tituloInicial = "Fire Sense"});

  @override
  _MenuAppBarState createState() => _MenuAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MenuAppBarState extends State<MenuAppBar> {
  late String tituloAtual;

  final List<Map<String, dynamic>> _telasDisponiveis = [
    {'titulo': 'Mapa', 'rota': MapScreen(), 'nomeTela': 'Mapa'},
    {'titulo': 'Alertas', 'rota': MapaAlertas(), 'nomeTela': 'Alertas'},
    {
      'titulo': 'Perfil Usuario',
      'rota': PerfilScreen(usuario: usuarioAtual),
      'nomeTela': 'Perfil Usuario'
    },
    {
      'titulo': 'Lista Usuários',
      'rota': ListaUsuariosScreen(usuarioAtual: usuarioAtual),
      'nomeTela': 'Lista Usuario'
    },
  ];

  @override
  void initState() {
    super.initState();
    tituloAtual = widget.tituloInicial;
  }

  void _navegarParaTela(BuildContext context, String nomeTela) {
    var telaSelecionada = _telasDisponiveis.firstWhere(
      (op) => op['nomeTela'] == nomeTela,
    );

    setState(() {
      tituloAtual = telaSelecionada['titulo'];
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => telaSelecionada['rota']),
    );
  }

  Future<void> _realizarLogoff(BuildContext context) async {
    await StorageService.clearToken(); // Limpa o token de autenticação
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redireciona para o login
      (Route<dynamic> route) => false, // Remove todas as telas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
      ),
      title: Text(
        tituloAtual,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.menu, color: Colors.white),
          onSelected: (String nomeTela) {
            if (nomeTela == 'Logoff') {
              _realizarLogoff(context);
            } else {
              _navegarParaTela(context, nomeTela);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              ..._telasDisponiveis
                  .where((op) => widget.usuario.permissoes.contains(op['nomeTela']))
                  .map((op) => PopupMenuItem<String>(
                        value: op['nomeTela'],
                        child: Text(
                          op['titulo'],
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
              PopupMenuItem<String>(
                value: 'Logoff',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Logoff", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
