import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/routes.dart';

class ChildInfoScreen extends StatefulWidget {
  const ChildInfoScreen({Key? key}) : super(key: key);

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

  // ✅ التحقق من صحة الاسم
  bool _isValidName(String? value) {
    if (value == null || value.isEmpty) return false;
    final nameRegex = RegExp(r'^[a-zA-Z ]+$');
    return value.length >= 3 && nameRegex.hasMatch(value);
  }

  // ✅ التحقق من التاريخ
  bool _isDateValid(DateTime? date) => date != null && !date.isAfter(DateTime.now());

  // ✅ التحقق من الرقم
  bool _isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_isDateValid(_birthDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid birth date')),
        );
        return;
      }

      // ✅ هنا يتم حفظ البيانات أو إرسالها إلى الباك
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields correctly')),
      );
    }
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
              // ✅ صورة الطفل
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.add_a_photo, size: 32)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ الاسم
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter child name';
                  if (!_isValidName(value)) return 'Name must be at least 3 letters';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ✅ تاريخ الميلاد
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
                  if (date != null) setState(() => _birthDate = date);
                },
              ),
              const SizedBox(height: 12),

              // ✅ الجنس
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Male', 'Female']
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 12),

              // ✅ الطول
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter height';
                  if (!_isNumeric(value)) return 'Height must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ✅ الوزن
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter weight';
                  if (!_isNumeric(value)) return 'Weight must be a number';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ✅ زر الحفظ
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
