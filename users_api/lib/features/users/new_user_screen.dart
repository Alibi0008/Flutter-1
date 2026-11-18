import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';
import 'widgets/state_views.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().length < 2) ? 'At least 2 characters' : null;

  String? _emailRule(String? v) {
    final s = v?.trim() ?? '';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
        ? null
        : 'Enter a valid email';
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final model = context.read<UsersModel>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _saving = true);
    try {
      await model.create(
        User.draft(
          name: _name.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
        ),
      );
      if (!mounted) return;
      nav.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New user')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: _required,
          ),
          TextFormField(
            controller: _username,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: _required,
          ),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: _emailRule,
          ),
          const SizedBox(height: 24),
          FilledButton(
            // null = disabled while the request is in flight
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
