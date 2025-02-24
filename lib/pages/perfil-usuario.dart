import 'package:flutter/material.dart';
import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aps/services/storage_service.dart';
import 'package:aps/pages/lista-usuarios.dart';

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
  late String _perfilSelecionado;
  bool _editando = false;
  late String _loginAntigo;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _loginController = TextEditingController(text: widget.usuario.usuario);
    _perfilSelecionado = _getPerfilNome(widget.usuario.perfil);
    _loginAntigo = widget.usuario.usuario; // Armazena o login antigo
  }

  /// Retorna o nome do perfil com base no código
  String _getPerfilNome(int codPerfil) {
    switch (codPerfil) {
      case 1:
        return "Administrador";
      case 2:
        return "Usuário";
      default:
        return "Desconhecido";
    }
  }

  /// Retorna o código do perfil com base no nome selecionado
  int _getPerfilCodigo(String nomePerfil) {
    switch (nomePerfil) {
      case "Administrador":
        return 1;
      case "Usuário":
        return 2;
      default:
        return 0; // Código inválido
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    String nome = _nomeController.text.trim();
    String login = _loginController.text.trim();
    int perfilCodigo = _getPerfilCodigo(_perfilSelecionado); // Converte para código

    Map<String, dynamic> dadosAtualizados = {
      'nome': nome,
      'login': login,
      'loginAntigo': _loginAntigo,
      'perfil': perfilCodigo, // Agora envia o código do perfil
    };

    const String apiUrl =
        'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/Usuario/AtualizarUsuario';

    try {
      String? token = await StorageService.getToken();
      if (token == null) {
        _showSnackBar('Usuário não autenticado. Faça login novamente.');
        return;
      }

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
        
        // Aguarda a mensagem antes de navegar
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ListaUsuariosScreen(usuarioAtual: widget.usuario)),
          );
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
                    "Seu perfil: $_perfilSelecionado",
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
                          _buildPerfilDropdown(),
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

  Widget _buildPerfilDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Perfil",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _perfilSelecionado,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: ["Administrador", "Usuário"]
                .map((perfil) => DropdownMenuItem(value: perfil, child: Text(perfil)))
                .toList(),
            onChanged: _editando ? (value) => setState(() => _perfilSelecionado = value!) : null,
          ),
        ],
      ),
    );
  }
}
