import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionStatusScreen extends StatefulWidget {
  const ConnectionStatusScreen({super.key});

  @override
  State<ConnectionStatusScreen> createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen> {
  bool _isConnected = false;
  bool _isLoading = true;
  String _authStatus = "Checking...";

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    setState(() => _isLoading = true);
    try {
      // Check if Firebase is initialized
      final app = Firebase.app();
      debugPrint('Firebase app name: ${app.name}');
      debugPrint('Firebase options: ${app.options.projectId}');

      // Check Firebase Auth status
      debugPrint(
        'Firebase Auth initialized: ${FirebaseAuth.instance.app.name}',
      );

      setState(() {
        _isConnected = true;
        _authStatus = "Auth Enabled";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _authStatus = "Error: $e";
        _isLoading = false;
      });
      debugPrint('Firebase connection check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Firebase Connection'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final bool isConnected = _isConnected;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Light grey professional background
      appBar: AppBar(
        title: const Text(
          'System Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Visual Indicator (Icon)
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isConnected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    size: 40,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),

                // Status Text
                Text(
                  isConnected ? 'Firebase Online' : 'Connection Failed',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 12),

                // Detailed Subtext
                Text(
                  isConnected
                      ? 'All services are initialized and ready to use.'
                      : 'We couldn\'t establish a link with the database. Please check your config.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Auth Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Auth Status: $_authStatus',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    isConnected ? 'STABLE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
