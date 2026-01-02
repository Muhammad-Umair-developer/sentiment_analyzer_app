import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Ensure this matches your login page file name

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;

  // --- DELETE ACCOUNT LOGIC ---
  Future<void> _deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      // 1. Re-authenticate the user (Required by Firebase for sensitive actions)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Delete the user
      await user.delete();

      _showSnackBar("Account deleted successfully.");

      // 3. Navigate back to Login Page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackBar("Incorrect password. Please try again.");
      } else {
        _showSnackBar("Error: ${e.message}");
      }
    } catch (e) {
      _showSnackBar("An unexpected error occurred.");
    }
  }

  // --- UI HELPERS ---
  void _showDeleteConfirmation() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Account?",
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "This action is permanent. Please enter your password to confirm deletion.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context);
                _deleteAccount(passwordController.text);
              }
            },
            child: const Text(
              "Delete Permanently",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(
    String title,
    String label,
    Function(String) onUpdate,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onUpdate(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing _changePassword, _updateName, and _showSnackBar methods) ...
  Future<void> _changePassword(String newPassword) async {
    try {
      if (newPassword.length < 6) throw "Password too short";
      await _auth.currentUser?.updatePassword(newPassword);
      _showSnackBar("Password updated successfully!");
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  Future<void> _updateName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName);
      _showSnackBar("Name updated! Refresh to see changes.");
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEF1),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("Account Customization"),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: "Display Name",
            subtitle: _auth.currentUser?.displayName ?? "Not Set",
            onTap: () =>
                _showUpdateDialog("Name", "Enter new name", _updateName),
          ),
          _buildSettingsTile(
            icon: Icons.lock_reset_outlined,
            title: "Change Password",
            subtitle: "Update your security",
            onTap: () => _showUpdateDialog(
              "Password",
              "Enter new password",
              _changePassword,
            ),
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("App Settings"),
          _buildSettingsTile(
            icon: Icons.notifications_none_outlined,
            title: "Notifications",
            subtitle: "Manage alerts and sounds",
            onTap: () {},
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("Danger Zone"),
          _buildSettingsTile(
            icon: Icons.delete_forever_outlined,
            title: "Delete Account",
            subtitle: "This action cannot be undone",
            color: Colors.redAccent,
            onTap: _showDeleteConfirmation, // Trigger the confirmation dialog
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              "App Version 1.0.0",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFF1967B2),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
