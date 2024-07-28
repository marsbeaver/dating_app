import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thank you')),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () => {Navigator.pop(context)},
              child: const Text('Home'))
        ],
      ),
    );
  }
}
