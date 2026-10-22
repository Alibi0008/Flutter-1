import 'package:flutter/material.dart';

import 'groups.dart';
import 'validators.dart';

void unfocusOnTapOutside(PointerDownEvent _) {
  FocusManager.instance.primaryFocus?.unfocus();
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.name,
    required this.email,
    required this.password,
    required this.confirm,
    required this.birthDate,
    required this.emailFocus,
    required this.group,
    required this.birth,
    required this.agreed,
    required this.onGroupChanged,
    required this.onAgreedChanged,
    required this.onPasswordChanged,
    required this.onPickBirth,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirm;
  final TextEditingController birthDate;
  final FocusNode emailFocus;
  final String? group;
  final DateTime? birth;
  final bool agreed;
  final ValueChanged<String?> onGroupChanged;
  final ValueChanged<bool> onAgreedChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onPickBirth;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: name,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => emailFocus.requestFocus(),
              onTapOutside: unfocusOnTapOutside,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: validateName,
            ),
            TextFormField(
              controller: email,
              focusNode: emailFocus,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onTapOutside: unfocusOnTapOutside,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
              ),
              validator: validateEmail,
            ),
            TextFormField(
              controller: password,
              obscureText: true,
              textInputAction: TextInputAction.next,
              onTapOutside: unfocusOnTapOutside,
              onChanged: onPasswordChanged,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
              ),
              validator: validatePassword,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${password.text.length} of 8'),
            ),
            TextFormField(
              controller: confirm,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onTapOutside: unfocusOnTapOutside,
              onFieldSubmitted: (_) {
                if (agreed) onSubmit();
              },
              decoration: const InputDecoration(labelText: 'Confirm password'),
              validator: (v) => validateConfirm(v, password.text),
            ),
            DropdownButtonFormField<String>(
              initialValue: group,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(labelText: 'Group'),
              items: [
                for (final g in groups)
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: onGroupChanged,
              validator: validateGroup,
            ),
            TextFormField(
              controller: birthDate,
              readOnly: true,
              onTap: onPickBirth,
              onTapOutside: unfocusOnTapOutside,
              decoration: InputDecoration(
                labelText: 'Date of birth',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: onPickBirth,
                ),
              ),
              validator: (_) => validateBirth(birth),
            ),
            CheckboxListTile(
              value: agreed,
              onChanged: (v) => onAgreedChanged(v ?? false),
              title: const Text('I agree to the rules'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: agreed ? onSubmit : null,
                child: const Text('Sign up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
