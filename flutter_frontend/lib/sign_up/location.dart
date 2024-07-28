import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:country_picker/country_picker.dart';
import 'package:logger/logger.dart';

class Location extends StatefulWidget {
  final Function changePage;
  const Location({super.key, required this.changePage});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final logger = Logger();
  final locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  String location = 'United States (US)';

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'location', value: location);
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Text(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                'Select your current location: '),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        setState(() {
                          location = country.displayNameNoCountryCode;
                        });
                      });
                },
                child: Text(location)),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => {
                          setState(() {
                            widget.changePage('birthDate');
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
                                widget.changePage('email');
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
