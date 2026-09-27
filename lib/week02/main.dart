// ignore_for_file: avoid_print

import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library(items: rawBooks.map(Book.fromJson).toList());
  library.open();

  print(library.buildReport());
  print('Opened at: ${library.openedAt}');
  print('Titles: ${library.everyTitle}');
  print('Books after 2010: ${library.booksPublishedAfter2010}');
  print('Average pages: ${library.averagePageCount}');
  print('Books by author: ${library.booksByAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genresPresent.map((genre) => genre.label).toSet()}');
  print('Country of Gamma: ${library.countryOf('Design Patterns')}');
  library.displayLines.forEach(print);

  final books = library.items.whereType<Book>().toList();
  print('Stats: ${statsOf(books)}');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('Shelf support is loose')));
}
