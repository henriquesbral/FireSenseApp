import 'package:flutter/material.dart';
import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aps/services/storage_service.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;

  PerfilScreen({required this.usuario});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _loginController;
  late String _perfilDescricao;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _loginController = TextEditingController(text: widget.usuario.login);
    _perfilDescricao = _getPerfilDescricao(widget.usuario.codPerfil);
  }

  /// Retorna a descrição do perfil com base no `codPerfil`
  String _getPerfilDescricao(int codPerfil) {
    switch (codPerfil) {
      case 1:
        return "Administrador";
      case 2:
        return "Usuário";
      default:
        return "Desconhecido";
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      String nome = _nomeController.text;
      String login = _loginController.text;

      Map<String, dynamic> dadosAtualizados = {
        'nome': nome,
        'login': login,
        'codPerfil': widget.usuario.codPerfil, // Mantendo o perfil inalterado
      };

      final String apiUrl =
          'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/Usuario/Atualizar';

      String? token = await StorageService.getToken();
      if (token == null) {
        _showSnackBar('Usuário não autenticado. Faça login novamente.');
        return;
      }

      try {
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(dadosAtualizados),
        );

        if (response.statusCode == 200) {
          _showSnackBar('Perfil atualizado com sucesso!');
          setState(() {
            _editando = false;
          });
        } else if (response.statusCode == 401) {
          _showSnackBar('Sessão expirada. Faça login novamente.');
          await StorageService.clearToken();
        } else {
          _showSnackBar('Erro ao atualizar perfil.');
        }
      } catch (e) {
        _showSnackBar('Erro de conexão.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(usuario: widget.usuario, tituloInicial: "Perfil Usuário"),
      body: Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Olá, ${widget.usuario.nome}",
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Seu perfil: $_perfilDescricao",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          _buildEditableField("Nome", _nomeController),
                          _buildEditableField("Login", _loginController),
                          _buildReadOnlyField("Perfil", _perfilDescricao),
                          SizedBox(height: 40),
                          Center(
                            child: MaterialButton(
                              onPressed: () {
                                if (_editando) {
                                  _salvarAlteracoes();
                                } else {
                                  setState(() {
                                    _editando = true;
                                  });
                                }
                              },
                              height: 50,
                              color: _editando ? Colors.green : Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  _editando ? "Salvar Alterações" : "Editar Perfil",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            enabled: _editando,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
