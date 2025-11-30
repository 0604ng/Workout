// FILE: lib/presentation/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../presentation/widgets/app_text_field.dart';
import '../../presentation/widgets/primary_button.dart';
import '../../injection_container.dart';
import '../state/auth_provider.dart' as local;
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword(local.AuthProvider auth) async {
    final email = _email.text.trim();

    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email')),
        );
      }
      return;
    }

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email')),
        );
      }
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email for reset link'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<local.AuthProvider>(
      create: (_) => sl<local.AuthProvider>(),
      child: Consumer<local.AuthProvider>(builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Reset Password')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email and we\'ll send you a link to reset your password',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  hint: 'Enter your registered email',
                  controller: _email,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: auth.isLoading ? 'Sending...' : 'Send reset link',
                  onPressed: auth.isLoading
                      ? () {} // ✅ Truyền empty function thay vì null
                      : () => _handleResetPassword(auth),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}