import 'package:aps/pages/perfil-usuario.dart';
import 'package:flutter/material.dart';
import 'usuario.dart';
import 'package:aps/pages/mapa-dashboard.dart';
import 'package:aps/pages/mapa-alertas.dart';
import 'package:aps/pages/cadastro.dart';

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

  final List<Map<String, dynamic>> opcoes = [
    {'titulo': 'Mapa', 'rota': MapScreen(), 'nomeTela': 'Mapa'},
    {'titulo': 'Alertas', 'rota': MapaAlertas(), 'nomeTela': 'Alertas'},
    {'titulo': 'Cadastro', 'rota': CadastroScreen(), 'nomeTela': 'Cadastro'},
    {'titulo': 'Perfil Usuario', 'rota': PerfilScreen(usuario: usuarioAtual,), 'nomeTela': 'Perfil Usuario'},
  ];

  @override
  void initState() {
    super.initState();
    tituloAtual = widget.tituloInicial;
  }

  void _navegarParaTela(BuildContext context, String nomeTela) {
    var telaSelecionada = opcoes.firstWhere((op) => op['nomeTela'] == nomeTela);

    setState(() {
      tituloAtual = telaSelecionada['titulo'];
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => telaSelecionada['rota']),
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
          onSelected: (String nomeTela) => _navegarParaTela(context, nomeTela),
          itemBuilder: (BuildContext context) {
            return opcoes
                .where((op) => widget.usuario.permissoes.contains(op['nomeTela']))
                .map((op) => PopupMenuItem<String>(
                      value: op['nomeTela'],
                      child: Text(
                        op['titulo'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ))
                .toList();
          },
        ),
      ],
    );
  }
}
