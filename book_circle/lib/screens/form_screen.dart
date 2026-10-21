import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

class FormArgs {
  const FormArgs(this.book);
  final Book? book;
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // R35: Controllers and FocusNodes are fields of State, created once, disposed
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _limitController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _descController;

  late final FocusNode _titleFocus;
  late final FocusNode _locationFocus;
  late final FocusNode _limitFocus;
  late final FocusNode _descFocus;

  late BookCategory _category;
  late DateTime _when;
  late bool _isDigital;
  bool _isSaving = false;

  // Stored to compare for R30 PopScope dirty check
  late final String _initialTitle;
  late final String _initialLocation;
  late final String _initialLimit;
  late final String _initialDesc;
  late final BookCategory _initialCategory;
  late final DateTime _initialWhen;
  late final bool _initialIsDigital;

  @override
  void initState() {
    super.initState();
    final book = widget.args.book ?? Book.empty();

    _titleController = TextEditingController(text: book.title);
    _locationController = TextEditingController(text: book.location);
    _limitController = TextEditingController(text: '${book.copyLimit}');
    _dateController = TextEditingController(text: formatDate(book.meetingAt));
    _timeController = TextEditingController(
      text: formatTimeOfDay(TimeOfDay.fromDateTime(book.meetingAt)),
    );
    _descController = TextEditingController(text: book.description ?? '');

    _titleFocus = FocusNode();
    _locationFocus = FocusNode();
    _limitFocus = FocusNode();
    _descFocus = FocusNode();

    _category = book.category;
    _when = book.meetingAt;
    _isDigital = book.isDigital;

    _initialTitle = _titleController.text;
    _initialLocation = _locationController.text;
    _initialLimit = _limitController.text;
    _initialDesc = _descController.text;
    _initialCategory = _category;
    _initialWhen = _when;
    _initialIsDigital = _isDigital;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _limitController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descController.dispose();

    _titleFocus.dispose();
    _locationFocus.dispose();
    _limitFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  // R30: PopScope canPop is !_dirty (current values vs ones the form opened with)
  bool get _dirty =>
      _titleController.text != _initialTitle ||
      _locationController.text != _initialLocation ||
      _limitController.text != _initialLimit ||
      _descController.text != _initialDesc ||
      _category != _initialCategory ||
      _when != _initialWhen ||
      _isDigital != _initialIsDigital;

  // R36: Date and time are readOnly fields opening showDatePicker/showTimePicker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    // R14: check mounted after await
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _when = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _when.hour,
        _when.minute,
      );
      _dateController.text = formatDate(_when);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    // R14: check mounted after await
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _when = DateTime(
        _when.year,
        _when.month,
        _when.day,
        picked.hour,
        picked.minute,
      );
      _timeController.text = formatTimeOfDay(picked);
      _dateController.text = formatDate(_when);
    });
  }

  // R17: Save simulates a one-second save, CircularProgressIndicator, no double-save
  Future<void> _save() async {
    final form = _formKey.currentState;
    // R33: one validate() on Save; no if-chain in onPressed
    if (form == null || !form.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    // R14: check mounted after await
    if (!mounted) {
      return;
    }

    final initial = widget.args.book;
    final savedBook = (initial ?? Book.empty()).copyWith(
      id: initial != null && initial.id.isNotEmpty
          ? initial.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _category,
      meetingAt: _when,
      location: _locationController.text.trim(),
      copyLimit: int.parse(_limitController.text.trim()),
      isDigital: _isDigital,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      clearDescription: _descController.text.trim().isEmpty,
    );

    // R26: form returns Item through pop
    Navigator.pop(context, savedBook);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.args.book == null;

    // R30: PopScope asks "Discard changes?" when dirty, clean or save never does
    return PopScope<Object?>(
      canPop: !_dirty || _isSaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (!context.mounted) {
          return;
        }
        if (discard == true) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        // R31: no BackButton, no leading: anywhere
        appBar: AppBar(title: Text(isNew ? 'New Book' : 'Edit Book')),
        // R37: The form scrolls; keyboard open on the last field, no stripes, Save reachable
        body: GestureDetector(
          // R35: onTapOutside dismisses the keyboard
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            // R33: autovalidateMode.onUserInteraction
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // R34: title 3-60 with maxLength and counter
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter book title (3–60 chars)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.length < 3 || trimmed.length > 60) {
                      return 'Title must be 3–60 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // R34: category required
                DropdownButtonFormField<BookCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: BookCategory.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon, size: 20),
                              const SizedBox(width: 8),
                              Text(c.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (cat) {
                    if (cat != null) {
                      setState(() => _category = cat);
                    }
                  },
                  validator: (cat) =>
                      cat == null ? 'Category is required' : null,
                ),
                const SizedBox(height: 16),
                // Mode switch: changes location label & validation
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isDigital,
                  title: const Text('Online meeting / Digital book'),
                  subtitle: const Text('Switches location to a web link'),
                  onChanged: (val) => setState(() => _isDigital = val),
                ),
                const SizedBox(height: 8),
                // R34: place required, and with mode on the label changes and must contain ://
                TextFormField(
                  controller: _locationController,
                  focusNode: _locationFocus,
                  textInputAction: TextInputAction.next,
                  keyboardType: _isDigital
                      ? TextInputType.url
                      : TextInputType.streetAddress,
                  decoration: InputDecoration(
                    labelText: _isDigital ? 'Meeting link' : 'Place / Shelf',
                    hintText: _isDigital
                        ? 'https://example.com/meet'
                        : 'Shelf 4 or Room 101',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Location is required';
                    }
                    if (_isDigital && !trimmed.contains('://')) {
                      return 'Digital links must contain ://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // R34: limit is int 1-500 and not below current count when editing
                TextFormField(
                  controller: _limitController,
                  focusNode: _limitFocus,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Copies available (limit)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final parsed = int.tryParse(v?.trim() ?? '');
                    if (parsed == null || parsed < 1 || parsed > 500) {
                      return 'Limit must be an integer between 1 and 500';
                    }
                    final currentReaders = widget.args.book?.count ?? 0;
                    if (parsed < currentReaders) {
                      return 'Cannot be less than current readers ($currentReaders)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // R36: Date and time readOnly fields opening pickers
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Meeting Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _pickDate,
                        // R34: date required and in the future for a new item
                        validator: (_) {
                          if (widget.args.book == null &&
                              !_when.isAfter(DateTime.now())) {
                            return 'Meeting must be in the future';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Optional text description
                TextFormField(
                  controller: _descController,
                  focusNode: _descFocus,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // R17: Save button with 1-second simulation, disabled while saving
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
