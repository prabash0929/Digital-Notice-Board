import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/custom_textfield.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Create Account', style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
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
                  const Text('Sign Up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('Join the workspace to manage notices.', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  CustomTextField(controller: _emailCtl, label: 'Work Email', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                  CustomTextField(controller: _passwordCtl, label: 'Secure Password', obscureText: true, validator: (v) => v!.length < 6 ? 'Too short' : null),
                  const SizedBox(height: 32),
                  if (authViewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(width: double.infinity, child: FilledButton(onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                           await authViewModel.register(_emailCtl.text, _passwordCtl.text);
                           if (mounted) Navigator.pop(context);
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }, child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)))),
                ]
              )
            )
          )
        )
      )
    );
  }
}
