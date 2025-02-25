import 'package:flutter/material.dart';
import 'package:Fire_Sense/model/app-bar-rotas.dart';
import 'package:Fire_Sense/model/usuario.dart';
import 'package:Fire_Sense/model/lista-usuario-model.dart';
import 'package:Fire_Sense/pages/perfil-usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Fire_Sense/services/storage_service.dart';

class ListaUsuariosScreen extends StatefulWidget {
  final Usuario usuarioAtual;

  ListaUsuariosScreen({required this.usuarioAtual});

  @override
  _ListaUsuariosScreenState createState() => _ListaUsuariosScreenState();
}

class _ListaUsuariosScreenState extends State<ListaUsuariosScreen> {
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarUsuarios);
    _searchController.dispose();
    super.dispose();
  }

  void _verificarAcesso() {
    if (widget.usuarioAtual.perfil != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Acesso negado. Apenas administradores podem visualizar esta tela.")),
        );
      });
    } else {
      _buscarUsuarios();
    }
  }

  Future<void> _buscarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl =
        'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/Usuario/Listar';

    String? token = await StorageService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Usuário não autenticado. Faça login novamente.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _usuarios = ListaUsuarios.fromJson(jsonResponse).usuarios;
          _usuariosFiltrados = List.from(_usuarios);
          _isLoading = false;
        });
      } else {
        _mostrarErro("Erro ao carregar usuários.");
      }
    } catch (e) {
      _mostrarErro("Erro de conexão com o servidor.");
    }
  }

  void _filtrarUsuarios() {
    setState(() {
      String pesquisa = _searchController.text.toLowerCase();
      _usuariosFiltrados = _usuarios.where((usuario) {
        return usuario.nome.toLowerCase().contains(pesquisa);
      }).toList();
    });
  }

  void _mostrarErro(String mensagem) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _abrirPerfilUsuario(Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PerfilScreen(usuario: usuario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
          usuario: widget.usuarioAtual, tituloInicial: "Lista de Usuários"),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar usuário",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _usuariosFiltrados.isEmpty
                    ? Center(child: Text("Nenhum usuário encontrado."))
                    : RefreshIndicator(
                        onRefresh: _buscarUsuarios,
                        child: ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: _usuariosFiltrados.length,
                          itemBuilder: (context, index) {
                            Usuario usuario = _usuariosFiltrados[index];

                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color:
                                      usuario.ativo ? Colors.green : Colors.red,
                                ),
                                title: Text(usuario.nome),
                                subtitle: Text(usuario.perfil == 1
                                    ? "Administrador"
                                    : "Usuário"),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: usuario.ativo
                                    ? () => _abrirPerfilUsuario(usuario)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
