import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart'; // Import Twitter package
import 'signup.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 1. EMAIL/PASSWORD LOGIN ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields.", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login failed", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. GOOGLE SIGN-IN LOGIC ---
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
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

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      _showSnackBar("Google Sign-In failed.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. TWITTER (X) SIGN-IN LOGIC ---
  Future<void> _handleTwitterSignIn() async {
    setState(() => _isLoading = true);
    try {
      final twitterLogin = TwitterLogin(
        apiKey: 'V8ONCYk44DfA1bi6CP9tnCoYY', // REPLACE WITH YOUR API KEY
        apiSecretKey:
            'WG0tRs4gOtc8lyOwr2piUqWr258UXHBuQ5q2upLJGacoFUw80y', // REPLACE WITH YOUR API SECRET
        redirectURI:
            'https://sentiment-analysis-app-cd56c.firebaseapp.com/__/auth/handler', // REPLACE WITH YOUR FIREBASE CALLBACK URL
      );

      final authResult = await twitterLogin.login();

      switch (authResult.status) {
        case TwitterLoginStatus.loggedIn:
          // Create credential for Firebase
          final AuthCredential credential = TwitterAuthProvider.credential(
            accessToken: authResult.authToken!,
            secret: authResult.authTokenSecret!,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
          break;
        case TwitterLoginStatus.cancelledByUser:
          _showSnackBar("Login cancelled by user.", Colors.orange);
          break;
        case TwitterLoginStatus.error:
          _showSnackBar(
            "Twitter login error: ${authResult.errorMessage}",
            Colors.redAccent,
          );
          break;
        default:
          _showSnackBar("An unknown error occurred.", Colors.redAccent);
      }
    } catch (e) {
      debugPrint("Twitter Sign-In Error: $e");
      _showSnackBar("Twitter Sign-In failed.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 4. PASSWORD RESET ---
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Enter your email first.", Colors.blueAccent);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar("Reset link sent to your email!", Colors.green);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GestureDetector(
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
                  backgroundColor: Colors.pink.withValues(alpha: 0.1),
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
                          "Welcome Back",
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
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            _buildInstantTextButton(
                              "Sign up",
                              const Color(0xFF1967B2),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildTextField("Email", controller: _emailController),
                        const SizedBox(height: 20),
                        _buildTextField(
                          "Password",
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _buildInstantTextButton(
                            "Forgot Password?",
                            const Color(0xFF3A51E3),
                            onPressed: _handleForgotPassword,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1967B2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Login",
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
                            _buildSocialIconButton(
                              FontAwesomeIcons.google,
                              const Color(0xFFDB4437),
                              26,
                              "Google",
                              onPressed: _handleGoogleSignIn,
                            ),
                            const SizedBox(width: 25),
                            // --- LINKED X (TWITTER) BUTTON ---
                            _buildSocialIconButton(
                              FontAwesomeIcons.xTwitter,
                              Colors.black,
                              26,
                              "X (Twitter)",
                              onPressed: _handleTwitterSignIn,
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
      ),
    );
  }

  Widget _buildInstantTextButton(
    String text,
    Color textColor, {
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        overlayColor: Colors.transparent,
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
        // onPressed: onPressed ?? () => debugPrint("$platformName icon pressed"),
        onPressed: onPressed,
      ),
    );
  }
}
