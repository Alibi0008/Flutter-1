import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    // R5: Destructuring record getter places
    final (:taken, :free) = book.places;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // R19: Stack avatar with Positioned badge using collection if
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: book.category.colorOf(colorScheme),
                    foregroundColor: colorScheme.onPrimary,
                    child: Icon(book.category.icon),
                  ),
                  if (free <= 0)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FULL',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onError),
                        ),
                      ),
                    )
                  else if (free <= 5)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$free left',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // R18: Expanded column with title (2 lines, ellipsis), date and place
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(book.meetingAt),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.secondary),
                    ),
                    Text(
                      book.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
              // R18: Favourite button on the right
              IconButton(
                icon: Icon(
                  book.isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: book.isFavourite
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
                onPressed: onToggleFavourite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
