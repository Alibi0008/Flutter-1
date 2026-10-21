import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.books,
    required this.themeMode,
    required this.onSaveProfile,
    required this.onChangeThemeMode,
  });

  final Profile profile;
  final List<Book> books;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onSaveProfile;
  final ValueChanged<ThemeMode> onChangeThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  late final FocusNode _nameFocus;
  late final FocusNode _groupFocus;

  @override
  void initState() {
    super.initState();
    // R38: Controllers initialised from the model
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
    _nameFocus = FocusNode();
    _groupFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      final updated = Profile(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      );
      widget.onSaveProfile(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // R38: "You are on N lists" is computed from the list on every build
    final currentName = widget.profile.name.trim();
    final onListsCount = currentName.isEmpty
        ? 0
        : widget.books.where((book) => book.contains(currentName)).length;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // R38: Name field saving on onSubmitted
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onFieldSubmitted: (_) => _groupFocus.requestFocus(),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Name is required'
                : null,
          ),
          const SizedBox(height: 16),
          // R38: Group field with RegExp validator and saving on onSubmitted
          TextFormField(
            controller: _groupController,
            focusNode: _groupFocus,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Group',
              hintText: 'e.g. CS-201 or BOOK-1',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school_outlined),
            ),
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Group is required';
              }
              final regex = RegExp(r'^[A-Za-z0-9\-]{2,10}$');
              if (!regex.hasMatch(value.trim())) {
                return '2–10 letters, numbers, or hyphens';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Save Profile')),
          const SizedBox(height: 24),
          // R38: Live count computed on every build
          Card(
            child: ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: Text('You are on $onListsCount lists'),
              subtitle: const Text('Borrowed reading club books'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // R22: themeMode from the three ChoiceChips in the profile
          Row(
            children: [
              ChoiceChip(
                label: const Text('System'),
                selected: widget.themeMode == ThemeMode.system,
                onSelected: (selected) {
                  if (selected) widget.onChangeThemeMode(ThemeMode.system);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Light'),
                selected: widget.themeMode == ThemeMode.light,
                onSelected: (selected) {
                  if (selected) widget.onChangeThemeMode(ThemeMode.light);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Dark'),
                selected: widget.themeMode == ThemeMode.dark,
                onSelected: (selected) {
                  if (selected) widget.onChangeThemeMode(ThemeMode.dark);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
