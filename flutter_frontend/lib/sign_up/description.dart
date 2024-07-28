import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Description extends StatefulWidget {
  final Function changePage;
  const Description({super.key, required this.changePage});

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final logger = Logger();

  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  String description = '';
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(
          key: 'description', value: descriptionController.text);
    } catch (e) {
      logger.e(e);
    }
  }

  String? validate(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a short description about yourself';
    } else if (value.split(" ").length < 5) {
      return 'Please enter at least a line of 5 words';
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
                'Enter a short description about yourself: \n'),
            const Text(
                'This will be visible in your profile, and will help other users know you better!'),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) => validate(value),
              decoration: const InputDecoration(
                label: Text('Enter a short description'),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: descriptionController,
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
                            widget.changePage('interests');
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
                                {
                                  Navigator.pushNamed(
                                      context, '/signup/confirm');
                                }
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
