import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({
    super.key,
    required this.books,
    required this.onOpenDetail,
    required this.onToggleFavourite,
    this.isFavouritesOnly = false,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpenDetail;
  final ValueChanged<Book> onToggleFavourite;
  final bool isFavouritesOnly;

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final TextEditingController _searchController = TextEditingController();
  BookCategory? _selectedCategory;
  bool _includePast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _includePast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    // R7: Lists are built with where / map / any
    final filtered = widget.books.where((book) {
      if (widget.isFavouritesOnly && !book.isFavourite) {
        return false;
      }
      if (_selectedCategory != null && book.category != _selectedCategory) {
        return false;
      }
      if (!_includePast && book.isPast) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchTitle = book.title.toLowerCase().contains(query);
        final matchLocation = book.location.toLowerCase().contains(query);
        if (!matchTitle && !matchLocation) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        // R21: Search field with clear button when not empty
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search books or places...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
        // R21: Horizontally scrolling row of ChoiceChips without fixed height or shrinkWrap
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (_) => setState(() => _selectedCategory = null),
              ),
              for (final cat in BookCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(cat.label),
                  avatar: Icon(cat.icon, size: 18),
                  selected: _selectedCategory == cat,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              ],
            ],
          ),
        ),
        // R21: FilterChip for past items
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: FilterChip(
              label: const Text('Include past books'),
              selected: _includePast,
              onSelected: (val) => setState(() => _includePast = val),
            ),
          ),
        ),
        // R20: LayoutBuilder deciding ListView vs GridView (cells <= 360 px at >= 600 px)
        Expanded(
          child: filtered.isEmpty
              ? (widget.isFavouritesOnly && widget.books.isEmpty
                    ? const EmptyState(
                        icon: Icons.favorite_border,
                        message: 'No favourite books yet',
                      )
                    : EmptyState(
                        icon: Icons.search_off,
                        message: 'No books match your criteria',
                        buttonText: 'Reset filters',
                        onButtonPressed: _clearFilters,
                      ))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      final columns = (constraints.maxWidth / 360).ceil();
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => BookCard(
                          book: filtered[index],
                          onTap: () => widget.onOpenDetail(filtered[index]),
                          onToggleFavourite: () =>
                              widget.onToggleFavourite(filtered[index]),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => BookCard(
                        book: filtered[index],
                        onTap: () => widget.onOpenDetail(filtered[index]),
                        onToggleFavourite: () =>
                            widget.onToggleFavourite(filtered[index]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
