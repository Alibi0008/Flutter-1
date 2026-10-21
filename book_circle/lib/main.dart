import 'package:flutter/material.dart';

import 'data/sample_books.dart';
import 'models/book.dart';
import 'models/profile.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/library_tab.dart';
import 'screens/profile_tab.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // R11: ThemeMode lives in MyApp's State, above MaterialApp
  ThemeMode _themeMode = ThemeMode.system;

  void _changeThemeMode(ThemeMode mode) {
    // R12: setState wraps the change only
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6750A4);

    return MaterialApp(
      title: 'Book Circle',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      // R22: ColorScheme.fromSeed for theme and darkTheme (Brightness.dark)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.home,
      // R25: routes: holds the shell; onGenerateRoute builds detail and form
      routes: {
        Routes.home: (_) => HomeShell(
          themeMode: _themeMode,
          onChangeThemeMode: _changeThemeMode,
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.detail &&
            settings.arguments is DetailArgs) {
          return MaterialPageRoute<void>(
            builder: (_) =>
                DetailScreen(args: settings.arguments as DetailArgs),
          );
        }
        if (settings.name == Routes.form && settings.arguments is FormArgs) {
          return MaterialPageRoute<Book>(
            builder: (_) => FormScreen(args: settings.arguments as FormArgs),
          );
        }
        return null;
      },
      // R25: onUnknownRoute shows "Not found"
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onChangeThemeMode,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChangeThemeMode;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // R10: Item list and profile live in shell's State
  List<Book> _books = sampleBooks();
  Profile _profile = const Profile.empty();
  int _selectedTab = 0;

  void _replaceBook(Book updated) {
    // R12: setState wraps the change only
    setState(() {
      final index = _books.indexWhere((b) => b.id == updated.id);
      if (index < 0) {
        _books = [..._books, updated];
      } else {
        // R7: sorting/updating copies, never in place
        _books = [..._books]..[index] = updated;
      }
    });
  }

  void _deleteBook(String id) {
    setState(() {
      _books = _books.where((b) => b.id != id).toList();
    });
  }

  void _toggleFavourite(Book book) {
    _replaceBook(book.copyWith(isFavourite: !book.isFavourite));
  }

  // R28: Tab switches requested go through a shell callback
  void _switchTab(int index) {
    setState(() => _selectedTab = index);
  }

  // R27: Caller awaits pushNamed<Item>, checks null and mounted, then setState
  Future<void> _openForm([Book? book]) async {
    final result = await Navigator.of(context)
        .pushNamed<Book>(Routes.form, arguments: FormArgs(book));
    // R14 & R27: check result != null and mounted
    if (result != null && mounted) {
      _replaceBook(result);
    }
  }

  void _openDetail(Book book) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArgs(
        book: book,
        profile: _profile,
        onChange: _replaceBook,
        onDelete: _deleteBook,
        onEdit: _openForm,
        onSwitchToProfile: () => _switchTab(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      // Tab 1: Library
      LibraryTab(
        books: _books,
        onOpenDetail: _openDetail,
        onToggleFavourite: _toggleFavourite,
      ),
      // Tab 2: Favourites
      LibraryTab(
        books: _books.where((b) => b.isFavourite).toList(),
        onOpenDetail: _openDetail,
        onToggleFavourite: _toggleFavourite,
        isFavouritesOnly: true,
      ),
      // Tab 3: Profile
      ProfileTab(
        profile: _profile,
        books: _books,
        themeMode: widget.themeMode,
        onSaveProfile: (p) => setState(() => _profile = p),
        onChangeThemeMode: widget.onChangeThemeMode,
      ),
    ];

    const tabTitles = ['Library', 'Favourites', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(tabTitles[_selectedTab])),
      // R32: Drawer with About (AlertDialog) and Reset data (asks, then restores seed and clears profile)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Book Circle',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                // R32: closes drawer with Navigator.pop
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('About Book Circle'),
                    content: const Text(
                      'Book Circle is a reading club app to manage book discussions, copies limit, and attendee registrations.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset data'),
              onTap: () async {
                // R32: closes drawer with Navigator.pop
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset data?'),
                    content: const Text(
                      'This will restore default seed books and clear your profile.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                // R14: check mounted before setState
                if (confirmed == true && mounted) {
                  setState(() {
                    _books = sampleBooks();
                    _profile = const Profile.empty();
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: tabs[_selectedTab],
      // FAB only shown on Library and Favourites tabs
      floatingActionButton: _selectedTab == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('New Book'),
            ),
      // NavigationBar with three tabs
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
