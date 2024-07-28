import 'package:dating_app/sign_up/birth_date.dart';
import 'package:dating_app/sign_up/description.dart';
import 'package:dating_app/sign_up/email.dart';
import 'package:dating_app/sign_up/interests.dart';
import 'package:dating_app/sign_up/location.dart';
import 'package:dating_app/sign_up/mobile.dart';
import 'package:dating_app/sign_up/password.dart';
import 'package:dating_app/sign_up/user_handle.dart';
import 'package:dating_app/sign_up/username.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String page = 'username';

  void changePage(val) {
    setState(() {
      page = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Sign up'),
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
                      children: <Widget>[
                        if (page == 'username')
                          Username(changePage: changePage)
                        else if (page == 'password')
                          Password(changePage: changePage)
                        else if (page == 'birthDate')
                          Birthdate(changePage: changePage)
                        else if (page == 'location')
                          Location(changePage: changePage)
                        else if (page == 'email')
                          Email(changePage: changePage)
                        else if (page == 'userHandle')
                          UserHandle(changePage: changePage)
                        else if (page == 'mobile')
                          Mobile(changePage: changePage)
                        else if (page == 'interests')
                          Interests(changePage: changePage)
                        else if (page == 'description')
                          Description(changePage: changePage)
                      ],
                    ),
                  ),
                ))));
  }
}
