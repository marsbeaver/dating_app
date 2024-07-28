import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Username extends StatefulWidget {
  final Function changePage;
  final String? confirm;
  const Username({super.key, required this.changePage, this.confirm});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  final logger = Logger();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  String firstName = '';
  String lastName = '';
  String fname = '';
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'firstName', value: firstNameController.text);
      await storage.write(key: 'lastName', value: lastNameController.text);
    } catch (e) {
      logger.e(e);
    }
  }

  String? validate(value) {
    if (value == null || value.isEmpty) {
      return 'Please fill all fields';
    } else if (value.length < 2) {
      return 'Name length must be at least 2 characters';
    } else if (!RegExp(r'[AEIOUaeiou]').hasMatch(value)) {
      return 'Name must have at least 1 vowel';
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
                'Enter your name: '),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) => validate(value),
              decoration: const InputDecoration(label: Text('First Name')),
              controller: firstNameController,
            ),
            TextFormField(
              validator: (value) => validate(value),
              decoration: const InputDecoration(label: Text('Last Name')),
              controller: lastNameController,
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
                                widget.changePage('password');
                              })
                            }
                        },
                    child: const Text('Next'))
              ],
            ),
            Text(fname)
          ],
        ));
  }
}
