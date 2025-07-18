import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/routes.dart';
import '../utils/validation_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class ChildInfoScreen extends StatefulWidget {
  final VoidCallback? onSuccessCallback; // سيستخدم لتحديث البيانات فور الإضافة

  const ChildInfoScreen({Key? key, this.onSuccessCallback}) : super(key: key);

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _birthDate;
  String _gender = 'Male';
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a birth date')),
        );
        return;
      }

      if (!ValidationUtils.isDateValid(_birthDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid birth date')),
        );
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in again to continue.")),
        );
        return;
      }

      final uri = Uri.parse('http://localhost:3000/api/users/baby');

      final body = {
        "name": _nameController.text.trim(),
        "birthDate": _birthDate!.toIso8601String(),
        "gender": _gender,
        "height": _heightController.text.trim(),
        "weight": _weightController.text.trim(),
      };

      try {
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          final babyData = jsonDecode(response.body)['baby'];

          // تحديث البيانات في Provider
          await Provider.of<AuthService>(context, listen: false)
              .setSelectedBabyId(babyData['_id']);

          // تنفيذ callback لتحديث البيانات في Dashboard
          if (widget.onSuccessCallback != null) {
            widget.onSuccessCallback!(); //  سيُجدد البيانات في الشاشة الأم
          }

          // أو التنقل إلى Dashboard مع تحديث البيانات
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.dashboard,
          );
        } else {
          final errorMsg = jsonDecode(response.body)['message'] ?? 'Failed to add baby';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      } catch (e) {
        print("Error submitting child info: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Info'),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!kIsWeb)
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null ? const Icon(Icons.add_a_photo, size: 32) : null,
                  ),
                ),
              if (!kIsWeb) const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter child name';
                  if (!ValidationUtils.isValidName(value)) return 'Name must be at least 3 letters';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? 'Select Birth Date'
                      : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2022),
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthDate = date);
                  }
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Male', 'Female']
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter height';
                  if (!ValidationUtils.isNumeric(value)) return 'Height must be a number';
                  if (!ValidationUtils.isPositiveNumeric(value)) return 'Height must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter weight';
                  if (!ValidationUtils.isNumeric(value)) return 'Weight must be a number';
                  if (!ValidationUtils.isPositiveNumeric(value)) return 'Weight must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Save & Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}