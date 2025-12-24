import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign In
import 'login.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  // --- GOOGLE SIGN UP/IN LOGIC ---
  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        signInOption: SignInOption.standard,
      );

      // Force account selection
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in/Up to Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      // Navigate to Home directly as the account is now linked/created
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      _showSnackBar(
        "Google Sign-Up failed. Please try again.",
        Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- TRADITIONAL EMAIL SIGN UP LOGIC ---
  Future<void> _handleSignUp() async {
    if (_passwordController.text != _retypePasswordController.text) {
      _showSnackBar("Passwords do not match!", Colors.redAccent);
      return;
    }

    if (_emailController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        _showSnackBar(
          "Account created successfully! Please login.",
          Colors.green,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "An error occurred", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDEEF1),
        body: Stack(
          children: [
            Positioned(
              top: -80,
              left: -80,
              child: CircleAvatar(
                radius: 150,
                backgroundColor: Colors.pink.withOpacity(0.1),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          _buildInstantTextButton(
                            "Login",
                            const Color(0xFF1967B2),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildTextField("Full Name", controller: _nameController),
                      const SizedBox(height: 20),
                      _buildTextField("Email", controller: _emailController),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Password",
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Retype Password",
                        controller: _retypePasswordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1967B2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Center(
                        child: Text(
                          "Or continue with",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIconButton(
                            FontAwesomeIcons.facebookF,
                            const Color(0xFF1877F2),
                            30,
                            "Facebook",
                          ),
                          const SizedBox(width: 25),
                          // --- LINKED GOOGLE BUTTON ---
                          _buildSocialIconButton(
                            FontAwesomeIcons.google,
                            const Color(0xFFDB4437),
                            26,
                            "Google",
                            onPressed: _handleGoogleSignUp,
                          ),
                          const SizedBox(width: 25),
                          _buildSocialIconButton(
                            FontAwesomeIcons.xTwitter,
                            Colors.black,
                            26,
                            "X (Twitter)",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInstantTextButton(
    String text,
    Color textColor, {
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1967B2), width: 2.0),
        ),
      ),
    );
  }

  // Updated to accept onPressed
  Widget _buildSocialIconButton(
    IconData icon,
    Color color,
    double iconSize,
    String platformName, {
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD6D6D6), width: 1),
      ),
      child: IconButton(
        icon: FaIcon(icon, color: color, size: iconSize),
        onPressed: onPressed ?? () => debugPrint("$platformName icon pressed"),
      ),
    );
  }
}
