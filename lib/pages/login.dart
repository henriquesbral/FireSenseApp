import 'package:flutter/material.dart';
import 'package:aps/pages/cadastro.dart';
import 'package:aps/pages/mapa-dashboard.dart';
import 'package:aps/pages/location-permission.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor informe o usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor informe a senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                }, //_login,
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navega para a segunda tela
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroScreen()),
                  );
                },
                child: Text('Cadastrar-se'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Serializa os dados em JSON
      Map<String, String> loginData = {
        'username': username,
        'password': password,
      };
      String jsonBody = jsonEncode(loginData);

      // Chama a API para autenticar o usuário
      bool isAuthenticated = await authenticateUser(jsonBody);

      if (isAuthenticated) {
        // Navegar para a próxima tela ou mostrar uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sucesso')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      } else {
        // Mostrar uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario ou senha não encontrado')),
        );
      }
    }
  }

  Future<bool> authenticateUser(String jsonBody) async {
    final url = Uri.parse(
        'http://localhost:5018/api/auth'); // Substitua pela URL da sua API
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
}
