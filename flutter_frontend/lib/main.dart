import 'package:dating_app/dashboard/dashboard.dart';
import 'package:dating_app/login/login.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/sign_up/confirm.dart';
import 'package:dating_app/sign_up/signup.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(
              title: 'Welcome',
            ),
        '/signup': (context) => const Signup(),
        '/signup/confirm': (context) => const Confirm(),
        '/login': (context) => const Login(),
        '/dashboard': (context) => const Dashboard(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _page = 'username';
  final ApiService apiService = ApiService();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await apiService.isLoggedIn();
    if (loggedIn) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _changePage() {
    setState(() {
      if (_page == 'username') {
        _page = 'password';
      } else {
        _page = 'username';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
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
                          const Text(
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                              'Dating App'),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () =>
                                      {Navigator.pushNamed(context, '/signup')},
                                  child: const Text('Signup')),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    _checkLoginStatus();
                                  },
                                  child: const Text('Login'))
                            ],
                          )
                        ],
                      )))),
        ));
  }
}
