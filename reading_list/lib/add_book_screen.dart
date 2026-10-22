import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _unfocus(PointerDownEvent _) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text),
      year: int.tryParse(_year.text),
    );
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add book'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) {
                  if ((v ?? '').trim().length < 2) {
                    return 'At least 2 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _author,
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'Author is required';
                  return null;
                },
              ),
              TextFormField(
                controller: _pages,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                decoration: const InputDecoration(labelText: 'Pages'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'A whole number above 0';
                  return null;
                },
              ),
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onTapOutside: _unfocus,
                onFieldSubmitted: (_) => _save(),
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (v) {
                  final text = (v ?? '').trim();
                  if (text.isEmpty) return null;
                  final n = int.tryParse(text);
                  final maxYear = DateTime.now().year;
                  if (n == null || n < 1450 || n > maxYear) {
                    return 'A year between 1450 and $maxYear';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
