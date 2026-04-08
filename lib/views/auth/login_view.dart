import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/custom_textfield.dart';
import 'signup_view.dart';
import '../shared/background_gradient.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtl = TextEditingController(text: 'admin@smartboard.com');
  final _passwordCtl = TextEditingController(text: 'admin123');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420), 
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF374151)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10))],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.dashboard_rounded, size: 48, color: Color(0xFF3B82F6)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('Enter your credentials to access the board', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  CustomTextField(controller: _emailCtl, label: 'Email Address', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                  CustomTextField(controller: _passwordCtl, label: 'Password', obscureText: true, validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 24),
                  if (authViewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                           await authViewModel.login(_emailCtl.text, _passwordCtl.text);
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }, child: const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.white)))),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupView())),
                    child: const Text('Create an Account', style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.w600)),
                  )
                ]
              )
            )
          )
        )
      )
    );
  }
}
