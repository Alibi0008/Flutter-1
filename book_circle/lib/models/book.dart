import 'package:flutter/material.dart';

enum BookCategory {
  fantasy('Fantasy', Icons.auto_awesome),
  detective('Detective', Icons.search),
  classic('Classic', Icons.account_balance),
  science('Science', Icons.science_outlined),
  other('Other', Icons.book_outlined);

  const BookCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color colorOf(ColorScheme scheme) => switch (this) {
    BookCategory.fantasy => scheme.primary,
    BookCategory.detective => scheme.secondary,
    BookCategory.classic => scheme.tertiary,
    BookCategory.science => scheme.error,
    BookCategory.other => scheme.primaryContainer,
  };
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.category,
    required this.meetingAt,
    required this.location,
    required this.copyLimit,
    required this.borrowerNames,
    required this.isDigital,
    this.description,
    this.isFavourite = false,
  });

  Book.empty()
    : this(
        id: '',
        title: '',
        category: BookCategory.other,
        meetingAt: DateTime.now().add(const Duration(days: 1)),
        location: '',
        copyLimit: 1,
        borrowerNames: const [],
        isDigital: false,
        description: null,
        isFavourite: false,
      );

  final String id;
  final String title;
  final BookCategory category;
  final DateTime meetingAt;
  final String location;
  final int copyLimit;
  final List<String> borrowerNames;
  final bool isDigital;
  final String? description;
  final bool isFavourite;

  // R4 & R5: Derived getters
  int get count => borrowerNames.length;
  ({int taken, int free}) get places =>
      (taken: borrowerNames.length, free: copyLimit - borrowerNames.length);
  int get freePlaces => places.free;
  bool get isFull => places.free <= 0;
  bool get isPast => meetingAt.isBefore(DateTime.now());
  bool contains(String name) => borrowerNames.contains(name);

  Book copyWith({
    String? id,
    String? title,
    BookCategory? category,
    DateTime? meetingAt,
    String? location,
    int? copyLimit,
    List<String>? borrowerNames,
    bool? isDigital,
    String? description,
    bool clearDescription = false,
    bool? isFavourite,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    meetingAt: meetingAt ?? this.meetingAt,
    location: location ?? this.location,
    copyLimit: copyLimit ?? this.copyLimit,
    borrowerNames: borrowerNames != null
        ? List.unmodifiable(borrowerNames)
        : this.borrowerNames,
    isDigital: isDigital ?? this.isDigital,
    description: clearDescription ? null : description ?? this.description,
    isFavourite: isFavourite ?? this.isFavourite,
  );
}
