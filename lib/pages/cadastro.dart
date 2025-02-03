import 'package:aps/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CadastroScreen());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroScreen(),
    );
  }
}

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String nome = _nomeController.text;
      String sobrenome = _sobrenomeController.text;
      String senha = _senhaController.text;

      Map<String, String> loginData = {
        'nome': nome,
        'sobrenome': sobrenome,
        'nenha':senha
      };
      String jsonBody = jsonEncode(loginData);

      // Chama a API para autenticar o usuário
      bool isAuthenticated = await authenticateUser(jsonBody);

      if (isAuthenticated) {
        // Navegar para a próxima tela ou mostrar uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro Realizado Com Sucesso'))
        );
        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
      } else {
        // Mostrar uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro interno')),
        );
      }
    }
  }

  Future<bool> authenticateUser(String jsonBody) async {
    final url = Uri.parse('http://localhost:5018/api/Usuario/Adicionar'); // Substitua pela URL da sua API
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        // Se a API retornar um status 200, consideramos o login bem-sucedido
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          return true;
        } else {
          return false;
        }
      } else {
        // Caso contrário, o login falhou
        return false;
      }
    } catch (e) {
      // Tratar erros de conexão ou outros erros
      print('Error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _sobrenomeController,
                decoration: InputDecoration(labelText: 'Sobrenome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu sobrenome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  } else if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}