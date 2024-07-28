import 'package:dating_app/services/api_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Email extends StatefulWidget {
  final String? confirm;
  final Function changePage;
  const Email({super.key, required this.changePage, this.confirm});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  final logger = Logger();

  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ApiService apiService = ApiService();

  bool? unique;
  bool isLoading = false;
  String email = '';

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'email', value: emailController.text);
    } catch (e) {
      logger.e(e);
    }
  }

  void onEmailChanged(String value) {
    setState(() {
      email = value;
      unique = null; // Reset unique status when mobile changes
    });
  }

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an Email id';
    } else if (!EmailValidator.validate(value)) {
      return 'Please enter a valid Email id';
    }
    return null;
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await _writeValue();
        bool uniqueHolder = await apiService.checkUniqueEmail(email);
        if (uniqueHolder) {
          widget.changePage('mobile');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This email id is already taken')),
            );
          }
        }
      } catch (e) {
        logger.e('Error checking mobile uniqueness: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
              'Enter your email id: '),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            validator: validate,
            decoration: const InputDecoration(label: Text('Enter Email Id')),
            controller: emailController,
            onChanged: onEmailChanged,
          ),
          const SizedBox(height: 40),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => widget.changePage('location'),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _handleNext,
                  child: const Text('Next'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
