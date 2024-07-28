import 'package:dating_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final logger = Logger();

  final emailMobileController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ApiService apiService = ApiService();
  bool canLogIn = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailMobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validate(value) {
    if (value == null || value.isEmpty) {
      return 'Please fill all fields';
    }
    return null;
  }

  Future<void> _writeValue() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!RegExp(r'[a-z]').hasMatch(emailMobileController.text)) {
        await storage.write(key: 'mobile', value: emailMobileController.text);
        await storage.write(key: 'email', value: "");
      } else {
        await storage.write(key: 'email', value: emailMobileController.text);
        await storage.write(key: 'mobile', value: "");
      }
      await storage.write(key: 'password', value: passwordController.text);
      bool success = await apiService.loginRequest() ?? false;
      setState(() {
        _isLoading = false;
      });
      setState(() {
        if (success) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/dashboard');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed')),
          );
        }
      });
    } catch (e) {
      logger.e('Login page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Login'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: SizedBox(
                        height: 500,
                        width: 500,
                        child: Card(
                            semanticContainer: false,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 50, top: 100, right: 50, bottom: 100),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    validator: (value) => validate(value),
                                    controller: emailMobileController,
                                    decoration: const InputDecoration(
                                        label: Text('Email/Mobile')),
                                  ),
                                  TextFormField(
                                    validator: (value) => validate(value),
                                    controller: passwordController,
                                    decoration: const InputDecoration(
                                      label: Text('Password'),
                                    ),
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                  ),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () => {
                                                setState(() {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(
                                                      context, '/');
                                                })
                                              },
                                          child: const Text('Home')),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      _isLoading
                                          ? const CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed: () => {
                                                    if (_formKey.currentState!
                                                        .validate())
                                                      {_writeValue()}
                                                  },
                                              child: const Text('Login'))
                                    ],
                                  ),
                                ],
                              ),
                            ))))
              ],
            )));
  }
}
