import '../models/book.dart';

List<Book> sampleBooks() {
  final now = DateTime.now();

  return [
    // 1. Mandatory: Title with exactly 60 characters
    Book(
      id: 'book-1',
      title: 'A Reading Circle Book Title That Truly Fits Sixty Characters',
      category: BookCategory.classic,
      meetingAt: now.add(const Duration(days: 4, hours: 2)),
      location: 'Room 301, Main Library',
      copyLimit: 5,
      borrowerNames: const ['Aruzhan', 'Nursultan'],
      isDigital: false,
      description: 'Discussing the historical context and themes.',
      isFavourite: true,
    ),
    // 2. Mandatory: An item at its limit
    Book(
      id: 'book-2',
      title: 'Dune',
      category: BookCategory.science,
      meetingAt: now.add(const Duration(days: 6, hours: 5)),
      location: 'Central Hall',
      copyLimit: 2,
      borrowerNames: const ['Aruzhan', 'Daniyar'],
      isDigital: false,
      description: 'Epic science fiction masterpiece discussion.',
      isFavourite: false,
    ),
    // 3. Mandatory: A past item
    Book(
      id: 'book-3',
      title: 'The Hobbit',
      category: BookCategory.fantasy,
      meetingAt: now.subtract(const Duration(days: 3, hours: 4)),
      location: 'Cafeteria Cozy Corner',
      copyLimit: 8,
      borrowerNames: const ['Aruzhan', 'Mira', 'Kairat'],
      isDigital: false,
      description: 'Journey to the Lonely Mountain review.',
      isFavourite: true,
    ),
    // 4. Mandatory: An item with mode on (isDigital: true with URL link)
    Book(
      id: 'book-4',
      title: 'The Martian',
      category: BookCategory.science,
      meetingAt: now.add(const Duration(days: 2, hours: 1)),
      location: 'https://meet.example.com/martian-circle',
      copyLimit: 15,
      borrowerNames: const ['Dias'],
      isDigital: true,
      description: 'Online session covering survival and science.',
      isFavourite: false,
    ),
    // 5. Mandatory: An item without the optional text (description: null)
    Book(
      id: 'book-5',
      title: 'The Alchemist',
      category: BookCategory.classic,
      meetingAt: now.add(const Duration(days: 7, hours: 3)),
      location: 'Room 102',
      copyLimit: 4,
      borrowerNames: const ['Alina'],
      isDigital: false,
      description: null,
      isFavourite: false,
    ),
    // 6. Detective book
    Book(
      id: 'book-6',
      title: 'Sherlock Holmes: The Hound of the Baskervilles',
      category: BookCategory.detective,
      meetingAt: now.add(const Duration(days: 5, hours: 6)),
      location: 'Faculty Lounge',
      copyLimit: 6,
      borrowerNames: const ['Timur', 'Elena'],
      isDigital: false,
      description: 'Mystery analysis and deduction exercise.',
      isFavourite: true,
    ),
    // 7. Science book
    Book(
      id: 'book-7',
      title: 'Sapiens: A Brief History of Humankind',
      category: BookCategory.science,
      meetingAt: now.add(const Duration(days: 9, hours: 2)),
      location: 'Auditorium B',
      copyLimit: 10,
      borrowerNames: const ['Daniyar', 'Madina'],
      isDigital: false,
      description: 'Exploring cognitive and agricultural revolutions.',
      isFavourite: false,
    ),
    // 8. Fantasy book
    Book(
      id: 'book-8',
      title: 'The Name of the Wind',
      category: BookCategory.fantasy,
      meetingAt: now.add(const Duration(days: 12, hours: 4)),
      location: 'https://meet.example.com/fantasy-club',
      copyLimit: 7,
      borrowerNames: const ['Sanzhar'],
      isDigital: true,
      description: 'First day of Kvothe narrative discussion.',
      isFavourite: false,
    ),
    // 9. Classic book
    Book(
      id: 'book-9',
      title: 'Frankenstein',
      category: BookCategory.classic,
      meetingAt: now.subtract(const Duration(days: 10)),
      location: 'Room 205',
      copyLimit: 5,
      borrowerNames: const ['Aruzhan', 'Olzhas', 'Aidar'],
      isDigital: false,
      description: 'Gothic literature and ethics in science.',
      isFavourite: false,
    ),
    // 10. Detective book
    Book(
      id: 'book-10',
      title: 'The Silent Patient',
      category: BookCategory.detective,
      meetingAt: now.add(const Duration(days: 3, hours: 7)),
      location: 'Library Terrace',
      copyLimit: 5,
      borrowerNames: const ['Kamila'],
      isDigital: false,
      description: 'Psychological thriller debate.',
      isFavourite: false,
    ),
    // 11. Other category
    Book(
      id: 'book-11',
      title: 'Atomic Habits',
      category: BookCategory.other,
      meetingAt: now.add(const Duration(days: 8, hours: 5)),
      location: 'https://meet.example.com/habits-workshop',
      copyLimit: 12,
      borrowerNames: const ['Arman', 'Aruzhan', 'Zhanar'],
      isDigital: true,
      description: 'Practical self-improvement techniques.',
      isFavourite: true,
    ),
    // 12. Classic book
    Book(
      id: 'book-12',
      title: '1984',
      category: BookCategory.classic,
      meetingAt: now.add(const Duration(days: 14, hours: 3)),
      location: 'Reading Hall 1',
      copyLimit: 6,
      borrowerNames: const [],
      isDigital: false,
      description: 'Dystopian society and surveillance analysis.',
      isFavourite: false,
    ),
  ];
}
