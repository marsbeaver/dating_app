import 'package:dating_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class UserHandle extends StatefulWidget {
  final String? confirm;
  final Function changePage;
  const UserHandle({super.key, required this.changePage, this.confirm});

  @override
  State<UserHandle> createState() => _UserHandle();
}

class _UserHandle extends State<UserHandle> {
  final logger = Logger();
  final userHandleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final ApiService apiService = ApiService();

  bool? unique;
  bool isLoading = false;
  String userHandle = '';

  @override
  void dispose() {
    userHandleController.dispose();
    super.dispose();
  }

  Future<void> _writeValue() async {
    try {
      await storage.write(key: 'userHandle', value: userHandleController.text);
    } catch (e) {
      logger.e(e);
    }
  }

  void onuserHandleChanged(String value) {
    setState(() {
      userHandle = value;
      unique = null; // Reset unique status when mobile changes
    });
  }

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an UserHandle id';
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
        bool uniqueHolder = await apiService.checkUniqueUserHandle(userHandle);
        if (uniqueHolder) {
          widget.changePage('interests');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('This user handle is already taken')),
            );
          }
        }
      } catch (e) {
        logger.e('Error checking user handle uniqueness: $e');
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
              'Enter a unique handle: '),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            validator: validate,
            decoration:
                const InputDecoration(label: Text('Enter user handle ')),
            controller: userHandleController,
            onChanged: onuserHandleChanged,
          ),
          const SizedBox(height: 40),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => widget.changePage('mobile'),
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
