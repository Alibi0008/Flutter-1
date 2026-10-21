# Book Circle

Book Circle is a Flutter application designed for managing a reading club. It allows members to browse scheduled book club meetings, filter by category and status, toggle favourites, borrow or return copies under a strict capacity limit, edit profile details, and switch between light and dark themes.

## Domain

* **Item**: Book with title (3–60 chars), category (enhanced enum with icon and theme-aware colors), meeting date and time, location (physical room or web link for digital sessions), copy limit, and an unmodifiable list of readers who borrowed a copy.
* **Profile**: User profile containing name and academic/reading group with regular expression validation.
* **Capacity Limit**: Enforces maximum available copies against active readers, with visual status badges and action guardrails.

## Screenshots

| Phone Light | Phone Dark | Tablet Grid |
| :---: | :---: | :---: |
| ![Phone Light](screenshots/phone_light.png) | ![Phone Dark](screenshots/phone_dark.png) | ![Tablet Grid](screenshots/tablet_grid.png) |

## Decisions

The main list of items lives directly in the shell's State (`HomeShellState`) so that both the library and favourites tabs can access and filter it, while changes propagate cleanly through callbacks. The detail screen takes callbacks because it operates on a live item and needs to reflect real-time updates (such as borrowing or deleting) immediately without waiting for a screen pop, whereas the form is a modal creator/editor that only produces a final committed item when valid and saved, naturally returning it via `Navigator.pop`. We choose `LayoutBuilder` over `MediaQuery` because layout decisions should depend on the actual constraints provided by the parent widget rather than the global screen dimensions, allowing responsive adaptability inside split-screen or embedded views. The `PopScope` compares the current controller and picker values against snapshot values captured when the screen was opened (`_dirty`), ensuring that only forms with real unsaved edits ask for discard confirmation while clean forms and save operations exit immediately. With week 9's state management and persistence tools, I would replace ephemeral in-memory callbacks and lifted State with a reactive state manager (such as `ChangeNotifier` or `Bloc`/`Riverpod`) and persist data to a local database (such as SQLite or Hive) alongside REST API synchronization.
