import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../NetScope/services/auth_service.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = switch (e.code) {
          'email-already-in-use' => 'This email is already registered.',
          'weak-password' => 'Password should be at least 6 characters.',
          'invalid-email' => 'Please enter a valid email.',
          _ => 'Registration failed: ${e.message}',
        };
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Something went wrong: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // TextFormField(
                //   controller: _usernameController,
                //   decoration: const InputDecoration(labelText: "Username"),
                //   validator: (v) => (v == null || v.trim().isEmpty)
                //       ? "Enter a username"
                //       : null,
                // ),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "Enter a username"
                      : null,
                ),
                const SizedBox(height: 16),
                

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? "Enter a valid email"
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? "Password must be at least 6 characters"
                      : null,
                ),
                const SizedBox(height: 24),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Log in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
