import 'package:flutter/material.dart';

import 'format_date.dart';
import 'sign_up_form.dart';
import 'summary_card.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthDate = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthDate]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthDate.text = formatBirthDate(picked);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _done = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthDate]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: _done
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SummaryCard(
                  name: _name.text,
                  email: _email.text,
                  group: _group ?? '',
                  birthDate: _birthDate.text,
                ),
                TextButton(
                  onPressed: _startOver,
                  child: const Text('Start over'),
                ),
              ],
            )
          : SignUpForm(
              formKey: _formKey,
              name: _name,
              email: _email,
              password: _password,
              confirm: _confirm,
              birthDate: _birthDate,
              emailFocus: _emailFocus,
              group: _group,
              birth: _birth,
              agreed: _agreed,
              onGroupChanged: (g) => setState(() => _group = g),
              onAgreedChanged: (v) => setState(() => _agreed = v),
              onPasswordChanged: (_) => setState(() {}),
              onPickBirth: _pickBirth,
              onSubmit: _submit,
            ),
    );
  }
}
