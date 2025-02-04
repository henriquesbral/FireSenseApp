import 'package:flutter/material.dart';
import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late TextEditingController _perfilController;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _loginController = TextEditingController(text: widget.usuario.login);
    _perfilController = TextEditingController(text: widget.usuario.perfil);
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      String nome = _nomeController.text;
      String login = _loginController.text;
      String perfil = _perfilController.text;

      Map<String, String> dadosAtualizados = {
        'nome': nome,
        'login': login,
        'perfil': perfil,
      };

      final url = Uri.parse('http://localhost:5018/api/Usuario/Atualizar');
      final headers = {'Content-Type': 'application/json'};

      try {
        final response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(dadosAtualizados),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );

          setState(() {
            _editando = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar perfil.')),
          );
        }
      } catch (e) {
        print('Erro ao atualizar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(usuario: widget.usuario, tituloInicial: "Meu Perfil"),
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
                    "Meu Perfil",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Edite suas informações abaixo",
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
                          _buildEditableField("Perfil", _perfilController),
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
}
