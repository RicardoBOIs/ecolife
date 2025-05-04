import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../widgets/fancy_button.dart';
import 'register_page.dart';
import 'reset_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mail = TextEditingController();
  final _pwd  = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FlutterLogo(size: 88),
              const SizedBox(height: 24),
              TextFormField(
                controller: _mail,
                decoration: const InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email)),
                validator: (v) =>
                v != null && v.contains('@') ? null : 'Email Format Incorrect',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwd,
                decoration: const InputDecoration(
                    labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) =>
                v != null && v.length >= 6 ? null : 'At least 6 characters',
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FancyButton(
                text: 'Login',
                onTap: () async {
                  if (!_form.currentState!.validate()) return;
                  setState(() => _loading = true);
                  try {
                    await authService.value.signIn(email: _mail.text.trim(), password: _pwd.text);
                    if (mounted) {
                      Navigator.pushReplacementNamed(
                          context, '/home');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$e')));
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ResetPage())),
                  child: const Text('Forgot Password?')),
              const Divider(height: 32),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterPage())),
                  child: const Text('No account? Register')),
            ],
          ),
        ),
      ),
    ),
  );
}
