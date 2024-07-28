import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Password extends StatefulWidget {
  final Function changePage;
  final String? confirm;
  const Password({super.key, required this.changePage, this.confirm});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final logger = Logger();
  final passwordController = TextEditingController();
  final pwdconfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final storage = const FlutterSecureStorage();

  String password = '';

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'password', value: passwordController.text);
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    pwdconfirmController.dispose();
    super.dispose();
  }

  String? validate(value) {
    if (value == null || value.isEmpty) {
      return 'Please fill all fields';
    } else if (value.length < 8) {
      return 'Password length must be at least 8 characters';
    } else if (value != pwdconfirmController.text) {
      return 'Passwords must be the same to confirm';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Text(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                'Enter a password: '),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) => validate(value),
              decoration: const InputDecoration(label: Text('Enter Password')),
              controller: passwordController,
              obscureText: true,
              obscuringCharacter: '*',
            ),
            TextFormField(
              validator: (value) => validate(value),
              decoration:
                  const InputDecoration(label: Text('Confirm Password')),
              controller: pwdconfirmController,
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
                            widget.changePage('username');
                          })
                        },
                    child: const Text('Back')),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    onPressed: () => {
                          if (_formKey.currentState!.validate())
                            {
                              _writeValue(),
                              setState(() {
                                widget.changePage('birthDate');
                              })
                            }
                        },
                    child: const Text('Next'))
              ],
            ),
          ],
        ));
  }
}
