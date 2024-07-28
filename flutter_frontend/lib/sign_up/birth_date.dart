import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class Birthdate extends StatefulWidget {
  final Function changePage;
  const Birthdate({super.key, required this.changePage});

  @override
  State<Birthdate> createState() => _BirthdateState();
}

class _BirthdateState extends State<Birthdate> {
  final storage = const FlutterSecureStorage();
  final logger = Logger();
  DateTime _selectedDate = DateTime(1998, 3, 17);

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1940),
      firstDate: DateTime(1940),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(
          key: 'birthDate',
          value: DateFormat.yMMMd().format(_selectedDate).toString());
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            'Select your birth date: '),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () => {_selectDate(context)},
            child: Text(DateFormat.yMMMd().format(_selectedDate).toString())),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => {
                      setState(() {
                        widget.changePage('password');
                      })
                    },
                child: const Text('Back')),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
                onPressed: () => {
                      _writeValue(),
                      setState(() {
                        widget.changePage('location');
                      })
                    },
                child: const Text('Next'))
          ],
        ),
      ],
    );
  }
}
