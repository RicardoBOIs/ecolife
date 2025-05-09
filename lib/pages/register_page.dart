// register_page.dart
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../widgets/fancy_button.dart';
import 'reset_page.dart';
import 'package:ecolife/firestore_service.dart';
import 'database/UserDao.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.prefillEmail});


  final String? prefillEmail;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form      = GlobalKey<FormState>();

  final _mail      = TextEditingController();
  final _pwd       = TextEditingController();
  final _username  = TextEditingController();
  final _phone     = TextEditingController();
  final _location  = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null) {
      _mail.text = widget.prefillEmail!;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Register'),
      leading: const BackButton(),
    ),
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

              /* ─── Username ───────────────────────────── */
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v!.trim().isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 12),

              /* ─── Email ─────────────────────────────── */
              TextFormField(
                controller: _mail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) =>
                v != null && v.contains('@') ? null : 'Invalid email',
              ),
              const SizedBox(height: 12),

              /* ─── Password ──────────────────────────── */
              TextFormField(
                controller: _pwd,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'At least 6 characters',
              ),
              const SizedBox(height: 12),

              /* ─── Phone ─────────────────────────────── */
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => RegExp(r'^\d{10,15}$').hasMatch(v ?? '')
                    ? null
                    : '10–15 digits',
              ),
              const SizedBox(height: 12),

              /* ─── Location ──────────────────────────── */
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'City / State',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) =>
                v!.trim().isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 24),

              /* ─── Register Button ───────────────────── */
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FancyButton(
                text: 'Register',
                onTap: () async {
                  if (!_form.currentState!.validate()) return;

                  setState(() => _loading = true);
                  try {
                    // create Firebase Auth account
                    await authService.value.createAccount(
                      email: _mail.text.trim(),
                      password: _pwd.text,
                    );

                    //  update display name
                    await authService.value.updateUsername(
                        username: _username.text.trim());

                    //  save profile to Firestore
                    await FirestoreService().saveUserProfile(
                      username: _username.text,
                      phone: _phone.text,
                      location: _location.text,
                    );

                    // also cache locally in SQLite
                    await UserDao().EnsureUser(
                      email: _mail.text.trim(),
                      username: _username.text,
                      phone: _phone.text,
                      location: _location.text,
                    );

                    if (mounted) {
                      Navigator.pushReplacementNamed(
                          context, '/home');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResetPage()),
                ),
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
