import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Interests extends StatefulWidget {
  final Function changePage;
  const Interests({super.key, required this.changePage});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests> {
  final logger = Logger();
  final interestController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  String error = '';
  List<String> chosenInterests = [];
  List<String> interests = [
    'Reading',
    'Writing',
    'Soccer',
    'Piano',
    'Running',
    'Tennis'
  ];
  List<bool> selections = [];

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'interests', value: chosenInterests.join(','));
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  void dispose() {
    interestController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selections = List<bool>.filled(interests.length, false);
  }

  String? validate() {
    if (chosenInterests.length < 2) {
      return 'Please choose at least two interests';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                'Select topics of your interest from the list below:\n'),
            const SizedBox(
              height: 10,
            ),
            Wrap(
              spacing: 18.0,
              runSpacing: 18.0,
              children: interests.asMap().entries.map((entry) {
                int index = entry.key;
                String interest = entry.value;
                return SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        selections[index] = !selections[index];
                        if (selections[index] == true) {
                          chosenInterests.add(interest);
                        } else {
                          chosenInterests.remove(interest);
                        }
                      })
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selections[index] ? Colors.blue : Colors.purple[50],
                    ),
                    child: Text(interest),
                  ),
                );
              }).toList(),
            ),
            Text(error),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            widget.changePage('mobile');
                          })
                        },
                    child: const Text('Back')),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    onPressed: () => {
                          if (validate() == null)
                            {
                              _writeValue(),
                              setState(() {
                                widget.changePage('description');
                              })
                            }
                          else
                            setState(() {
                              {
                                error = validate()!;
                              }
                            })
                        },
                    child: const Text('Next'))
              ],
            ),
          ],
        ));
  }
}
