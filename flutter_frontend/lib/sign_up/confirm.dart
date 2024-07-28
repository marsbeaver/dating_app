import 'package:dating_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Confirm extends StatefulWidget {
  const Confirm({super.key});

  @override
  State<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  final logger = Logger();

  String page = 'confirm';
  String? firstName = '';
  String? location = '';
  String? birthDate = '';
  String? lastName = '';
  String? email = '';
  String? mobile = '';
  String? password = '';
  String? interests = '';
  String? description = '';
  String? userHandle = '';
  bool isLoading = false;

  final String apiUrl = '';

  final ApiService apiService = ApiService();

  final storage = const FlutterSecureStorage();
  void changePage(val) {
    setState(() {
      page = val;
    });
  }

  @override
  void initState() {
    super.initState();
    readValue();
  }

  Future<void> readValue() async {
    String? firstNameTemp = '';
    String? lastNameTemp = '';

    String? emailTemp = '';
    String? mobileTemp = '';
    String? interestsTemp = '';
    String? descriptionTemp = '';
    String? locationTemp = '';
    String? birthDateTemp = '';
    String? userHandleTemp = '';

    firstNameTemp = await storage.read(key: 'firstName');
    lastNameTemp = await storage.read(key: 'lastName');

    emailTemp = await storage.read(key: 'email');
    mobileTemp = await storage.read(key: 'mobile');
    interestsTemp = await storage.read(key: 'interests');
    descriptionTemp = await storage.read(key: 'description');
    locationTemp = await storage.read(key: 'location');
    birthDateTemp = await storage.read(key: 'birthDate');
    userHandleTemp = await storage.read(key: 'userHandle');
    setState(() {
      firstName = firstNameTemp;
      lastName = lastNameTemp;

      email = emailTemp;
      mobile = mobileTemp;
      interests = interestsTemp;
      description = descriptionTemp;
      location = locationTemp;
      birthDate = birthDateTemp;
      userHandle = userHandleTemp;
    });
  }

  Future<void> _handleNext() async {
    setState(() {
      isLoading = true;
    });

    try {
      await apiService.signupRequest();
      await storage.write(key: 'searchTerm', value: '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed up successfully')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      logger.e('Error signing up: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Confirm'),
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
                          children: <Widget>[
                            const Text(
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                'Your entered details: '),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@${userHandle!}'),
                                  Text('FirstName: ${firstName!}'),
                                  Text('LastName: ${lastName!}'),
                                  Text('Email: ${email!}'),
                                  Text('Mobile: ${mobile!}'),
                                  Text('Interests: ${interests!}'),
                                  Text('Description: ${description!}'),
                                  Text('Location: ${location!}'),
                                  Text('Birth Date: ${birthDate!}'),
                                  const SizedBox(
                                    height: 20,
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
                                          onPressed: () async =>
                                              {_handleNext()},
                                          child: const Text('Submit'))
                                    ],
                                  ),
                                ])
                          ],
                        ),
                      ),
                    )))
          ],
        ));
  }
}
