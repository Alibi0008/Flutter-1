import 'models.dart';

class Library {
  Library({List<LibraryItem>? items}) : items = [...?items];

  final List<LibraryItem> items;
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  void open() => openedAt = DateTime.now();

  String buildReport() =>
      _cachedReport ??= 'Library contains ${items.length} item(s).';

  List<Book> get _books => items.whereType<Book>().toList();

  List<String> get everyTitle => items.map((item) => item.title).toList();

  List<Book> get booksPublishedAfter2010 =>
      _books.where((book) => book.year > 2010).toList();

  // fold works for an empty list; reduce would throw before producing a value.
  double get averagePageCount => _books.isEmpty
      ? 0
      : _books.fold<int>(0, (total, book) => total + book.pages) / _books.length;

  Map<String, int> get booksByAuthor => _books.fold(<String, int>{}, (
    counts,
    book,
  ) => counts..update(book.author.name, (count) => count + 1, ifAbsent: () => 1));

  Set<String> get authorNames => _books.map((book) => book.author.name).toSet();

  Set<Genre> get genresPresent => _books.map((book) => book.genre).toSet();

  List<String> get displayLines => [
    'CATALOGUE',
    for (final book in _books) '${book.title} (${book.year})',
    ..._books.map((book) => book.author.name),
    if (_books.any((book) => book.pages == 0)) '(incomplete data)',
  ];
}
