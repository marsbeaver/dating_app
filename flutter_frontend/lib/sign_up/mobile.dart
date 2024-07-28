import 'package:dating_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class Mobile extends StatefulWidget {
  final String? confirm;
  final Function changePage;
  const Mobile({super.key, required this.changePage, this.confirm});

  @override
  State<Mobile> createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  final logger = Logger();
  final mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ApiService apiService = ApiService();

  bool? unique;
  bool isLoading = false;
  String mobile = '';

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'mobile', value: mobileController.text);
    } catch (e) {
      logger.e(e);
    }
  }

  void onMobileChanged(String value) {
    setState(() {
      mobile = value;
      unique = null; // Reset unique status when mobile changes
    });
  }

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    } else if (value.length < 10) {
      return 'Mobile number length must be at least 10 characters';
    } else if (!RegExp(r'[1234567890]').hasMatch(value)) {
      return 'Mobile number must be numeric';
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
        bool uniqueHolder = await apiService.checkUniqueMobile(mobile);
        if (uniqueHolder) {
          widget.changePage('userHandle');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('This mobile number is already taken')),
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
              'Enter your mobile number: '),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            validator: validate,
            decoration:
                const InputDecoration(label: Text('Enter Mobile Number')),
            controller: mobileController,
            onChanged: onMobileChanged,
          ),
          const SizedBox(height: 40),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => widget.changePage('email'),
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
