import 'package:flutter/foundation.dart';

import 'book.dart';

/// The cart: a plain Dart model. No widgets, no BuildContext.
class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => List.unmodifiable(_qty.keys);

  /// Number of distinct books.
  int get count => _qty.length;

  int get total =>
      _qty.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  int qtyOf(Book b) => _qty[b] ?? 0;

  /// Returns false (and does nothing) when the book is already in the cart.
  bool add(Book b) {
    if (_qty.containsKey(b)) return false;
    _qty[b] = 1;
    notifyListeners();
    return true;
  }

  void increment(Book b) {
    if (!_qty.containsKey(b)) return;
    _qty[b] = _qty[b]! + 1;
    notifyListeners();
  }

  void remove(Book b) {
    if (_qty.remove(b) == null) return;
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
