import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Safety fallback if user session is lost
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDEEF1),
      appBar: AppBar(
        title: const Text("User Profile"),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF1967B2),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: const Color(0xFF1967B2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user.displayName ?? "Anonymous User",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email ?? "No Email Available",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildProfileInfo(
              Icons.calendar_today,
              "Account Created",
              user.metadata.creationTime?.toString().split(' ')[0] ?? "N/A",
            ),
            _buildProfileInfo(
              Icons.verified_user_outlined,
              "User ID",
              user.uid,
            ),
            _buildProfileInfo(
              Icons.phone,
              "Phone Number",
              user.phoneNumber ?? "Not Linked",
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(thickness: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1967B2)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
