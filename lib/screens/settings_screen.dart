import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/child_info_screen.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime? lastHeightWeightUpdate;

  @override
  void initState() {
    super.initState();
    _loadLastUpdateDate();
  }

  Future<void> _loadLastUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_height_weight_update');
    if (timestamp != null) {
      setState(() {
        lastHeightWeightUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      });
    }
  }

  Future<void> _saveHeightWeightUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_height_weight_update', DateTime.now().millisecondsSinceEpoch);
    setState(() {
      lastHeightWeightUpdate = DateTime.now();
    });
  }

  void _showHeightWeightDialog() {
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Update Height & Weight"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: heightController, decoration: const InputDecoration(labelText: "Height (cm)")),
          TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight (kg)")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Later")),
        ElevatedButton(
          onPressed: () async {
            final authService = Provider.of<AuthService>(context, listen: false);
            final token = authService.token;
            final babyId = authService.selectedBabyId;

            if (token == null || babyId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing token or baby ID")));
              return;
            }

            final uri = Uri.parse("http://localhost:3000/api/babies/info/$babyId");

            final body = {
              "height": heightController.text.trim(),
              "weight": weightController.text.trim(),
            };

            try {
              final response = await http.put(
                uri,
                headers: {
                  "Authorization": "Bearer $token",
                  "Content-Type": "application/json",
                },
                body: jsonEncode(body),
              );

              Navigator.pop(context); // إغلاق الديالوج

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully")));
                await _saveHeightWeightUpdateDate(); // لحفظ آخر تحديث محليًا
              } else {
                final msg = jsonDecode(response.body)['message'] ?? 'Update failed';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $msg")));
              }
            } catch (e) {
              Navigator.pop(context);
              print("Error updating height & weight: $e");
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong")));
            }
          },
          child: const Text("Save"),
        )
      ],
    ),
  );
}







  void _editUserInfo(BuildContext context) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit User Info"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const Divider(),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm New Password"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final email = emailController.text.trim();
            final oldPass = oldPasswordController.text.trim();
            final newPass = newPasswordController.text.trim();
            final confirmNewPass = confirmNewPasswordController.text.trim();

            final authService = Provider.of<AuthService>(context, listen: false);
            final token = authService.token;
            final userId = authService.userId;

            if (token == null || userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User not authenticated")),
              );
              return;
            }

            final uri = Uri.parse('http://localhost:3000/api/users/$userId');

            final updateBody = {
              if (name.isNotEmpty) 'username': name,
              if (email.isNotEmpty) 'email': email,
              if (oldPass.isNotEmpty) 'oldPassword': oldPass,
              if (newPass.isNotEmpty) 'newPassword': newPass,
              if (confirmNewPass.isNotEmpty) 'confirmNewPassword': confirmNewPass,
            };

            try {
              final response = await http.put(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(updateBody),
              );

              Navigator.pop(context); // إغلاق الديالوج

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User info updated successfully")),
                );
              } else {
                final msg = jsonDecode(response.body)['message'];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed: $msg")),
                );
              }
            } catch (e) {
              Navigator.pop(context);
              print("Error: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Something went wrong")),
              );
            }
          },
          child: const Text("Save"),
        )
      ],
    ),
  );
}





void _editChildInfo(BuildContext context) {
  final authService = Provider.of<AuthService>(context, listen: false);
  final selectedBabyId = authService.selectedBabyId;
  final babies = authService.babies;

  if (selectedBabyId == null || babies.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No baby selected")),
    );
    return;
  }

  final selectedBaby = babies.firstWhere(
    (baby) => baby['_id'] == selectedBabyId,
    orElse: () => {},
  );

  if (selectedBaby.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Selected baby not found")),
    );
    return;
  }

  final nameController = TextEditingController(text: selectedBaby['name'] ?? '');
  final heightController = TextEditingController(text: selectedBaby['height']?.toString() ?? '');
  final weightController = TextEditingController(text: selectedBaby['weight']?.toString() ?? '');
  final gender = ValueNotifier<String>(selectedBaby['gender'] ?? 'Male');
  DateTime? birthDate = selectedBaby['birthDate'] != null
      ? DateTime.tryParse(selectedBaby['birthDate'])
      : null;

  void _submitUpdate() async {
    final token = authService.token;
    final babyId = authService.selectedBabyId;

    if (token == null || babyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing token or baby ID")),
      );
      return;
    }

    final uri = Uri.parse('http://localhost:3000/api/babies/info/$babyId');

    final body = {
      "babyName": nameController.text.trim(),
      "babyGender": gender.value,
      "height": heightController.text.trim(),
      "weight": weightController.text.trim(),
      "birthDate": birthDate?.toIso8601String(),
    };

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      Navigator.pop(context); // إغلاق الديالوج

      if (response.statusCode == 200) {
        await authService.fetchBabies(); // تحديث قائمة الأطفال
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Child info updated successfully")),
        );
        setState(() {});
      } else {
        final msg = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $msg")),
        );
      }
    } catch (e) {
      print("Error updating child info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  // عرض نافذة التعديل
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text("Edit Child Info"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Child Name"),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<String>(
                valueListenable: gender,
                builder: (context, value, _) {
                  final genderOptions = ['Male', 'Female'];
                  final safeValue = genderOptions.contains(value) ? value : 'Male';

                  return DropdownButtonFormField<String>(
                    value: safeValue,
                    items: genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) gender.value = val;
                    },
                    decoration: const InputDecoration(labelText: "Gender"),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  birthDate != null
                      ? "${birthDate?.day ?? '0'}/${birthDate?.month ?? '0'}/${birthDate?.year ?? '0'}"
                      : "Select Birth Date",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: birthDate ?? DateTime(2020),
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setDialogState(() {
                      birthDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _submitUpdate,
            child: const Text("Save"),
          ),
        ],
      ),
    ),
  );
}






  void _addNewChild() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChildInfoScreen(
          onSuccessCallback: () {
            Navigator.pop(context); // يرجع المستخدم للإعدادات بعد الإضافة
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Child added successfully")),
            );
          },
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    final daysSinceUpdate = lastHeightWeightUpdate == null
        ? 999
        : DateTime.now().difference(lastHeightWeightUpdate!).inDays;

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: ListView(
          key: const ValueKey("settingsList"),
          children: [
            if (daysSinceUpdate >= 7)
              ListTile(
                tileColor: Colors.orange[50],
                title: const Text("⏳ Please update your child's height & weight."),
                trailing: ElevatedButton(
                  onPressed: _showHeightWeightDialog,
                  child: const Text("Update"),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit User Info'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _editUserInfo(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.child_care),
              title: const Text('Edit Child Info'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _editChildInfo(context),
            ),
            const Divider(height: 1),
            // زر إضافة طفل جديد
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Another Child'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _addNewChild,
            ),
            const Divider(height: 1),
            // زر تسجيل الخروج
            ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        // تنفيذ تسجيل الخروج
                        Provider.of<AuthService>(context, listen: false).logout();
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
          ],
        ),
      ),
    );
  }
}
