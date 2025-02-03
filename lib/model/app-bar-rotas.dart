import 'package:flutter/material.dart';
import 'usuario.dart';
import 'package:aps/pages/mapa-dashboard.dart';
import 'package:aps/pages/mapa-alertas.dart';
import 'package:aps/pages/cadastro.dart';

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Usuario usuario;

  MenuAppBar({required this.usuario});

  // Lista de opções do menu
  final List<Map<String, dynamic>> opcoes = [
    {'titulo': 'Mapa', 'rota': MapScreen(), 'nomeTela': 'Mapa'},
    {'titulo': 'Alertas', 'rota': MapaAlertas(), 'nomeTela': 'Alertas'},
    {'titulo': 'Cadastro', 'rota': CadastroScreen(), 'nomeTela': 'Cadastro'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Fire Sense"),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String nomeTela) {
            // Buscar a tela correspondente na lista de opções
            var telaSelecionada = opcoes.firstWhere((op) => op['nomeTela'] == nomeTela);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => telaSelecionada['rota']),
            );
          },
          itemBuilder: (BuildContext context) {
            return opcoes
                .where((op) => usuario.permissoes.contains(op['nomeTela'])) // Filtra pelo perfil do usuário
                .map((op) => PopupMenuItem<String>(
                      value: op['nomeTela'],
                      child: Text(op['titulo']),
                    ))
                .toList();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}