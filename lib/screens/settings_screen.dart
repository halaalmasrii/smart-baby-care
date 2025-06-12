import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';

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
            onPressed: () {
              _saveHeightWeightUpdateDate();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully")));
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _editUserInfo(BuildContext context) {
    final nameController = TextEditingController(text: "Parent Name");
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: oldPasswordController, obscureText: true, decoration: const InputDecoration(labelText: "Old Password")),
            TextField(controller: newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: "New Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User info updated")));
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _editChildInfo(BuildContext context) {
    final nameController = TextEditingController(text: "Baby Name");
    final gender = ValueNotifier<String>("Female");
    final height = "68 cm";
    final weight = "7.5 kg";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Child Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Child Name")),
            ValueListenableBuilder(
              valueListenable: gender,
              builder: (context, value, _) => DropdownButtonFormField<String>(
                value: value as String,
                items: ["Male", "Female"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) {
                  if (val != null) gender.value = val;
                },
                decoration: const InputDecoration(labelText: "Gender"),
              ),
            ),
            const SizedBox(height: 8),
            Text("Current Height: $height"),
            Text("Current Weight: $weight"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Child info updated")));
            },
            child: const Text("Save"),
          )
        ],
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
          ],
        ),
      ),
    );
  }
}
