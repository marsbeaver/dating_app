import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class UserList extends StatelessWidget {
  final List<dynamic> users;
  final logger = Logger();
  UserList({super.key, required this.users});

  int calculateAge(String birthDateString) {
    try {
      final birthDate = DateFormat('yyyy-MM-dd').parse(birthDateString);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      logger.e('Error parsing date: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user = users[index];
        String birthDateString = user['BirthDate']?.split(' ')[0] ?? '';
        int age = calculateAge(birthDateString);

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        user['firstName'] != null
                            ? user['firstName'][0].toUpperCase()
                            : '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "@${user['UserHandle']} | Age: $age | Country: ${user['Location'] ?? 'Unknown'}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
