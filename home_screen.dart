import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tale_app_final/screens/library.dart';
import 'package:tale_app_final/screens/explore.dart';
import 'package:tale_app_final/screens/upload.dart';
import 'package:tale_app_final/screens/settings.dart';
import 'package:flutter/services.dart';
import 'story_reader_screen.dart';
import 'story_reader_screen1.dart';
import 'story_reader_screen2.dart';

class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Global keys to measure the "Menu" text and the overall stack.
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // This will hold the computed top offset for the overlapping cards.
  double cardTop = 0;

  final List<Map<String, String>> books = [
    {
      "title": "The Mystery of the Whispering Walls",
      "cover": "assets/images/coverpage1.jpg",
    },
    {
      "title": "Quest of Silver",
      "cover": "assets/images/coverpage2.jpg",
    },
    {
      "title": "Mystery of Time Capsule",
      "cover": "assets/images/coverpage3.jpg",
    },
  ];

  final Set<int> savedBooks = {};

  // Create a FlutterTts instance.
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    // After the first frame, measure the position of the "Menu" text relative to the stack.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? stackBox =
      _stackKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? menuBox =
      _menuKey.currentContext?.findRenderObject() as RenderBox?;
      if (stackBox != null && menuBox != null && mounted) {
        final Offset stackPosition = stackBox.localToGlobal(Offset.zero);
        final Offset menuPosition = menuBox.localToGlobal(Offset.zero);
        // Compute the vertical position of the bottom of the "Menu" text relative to the stack.
        final double newCardTop =
            (menuPosition.dy - stackPosition.dy) + menuBox.size.height + 8;
        setState(() {
          cardTop = newCardTop;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String firstName = widget.name.split(" ")[0];

    final List<Map<String, String>> filteredBooks = searchQuery.isEmpty
        ? []
        : books
        .where((book) =>
        book["title"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return WillPopScope(
      onWillPop: () async {
        if (searchQuery.isNotEmpty) {
          setState(() {
            searchQuery = '';
            _searchController.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: searchQuery.isEmpty
            ? _buildHomeContent(firstName)
            : _buildSearchResults(firstName, filteredBooks),
      ),
    );
  }

  /// When no search is active, we show the header and the overlapping cards.
  /// The "Menu" text is wrapped with _menuKey so we can measure its bottom position.
  Widget _buildHomeContent(String firstName) {
    // Use cardTop if measured; otherwise default to 200.
    double effectiveCardTop = cardTop > 0 ? cardTop : 200;
    // Calculate the total container height based on effectiveCardTop and the cards.
    double containerHeight = effectiveCardTop + (3 * 150) + 200;

    return SingleChildScrollView(
      child: SizedBox(
        key: _stackKey,
        height: containerHeight,
        child: Stack(
          children: [
            // Header area spanning the container.
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  ExcludeSemantics(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Image(
                        image: AssetImage('assets/images/logo1.png'),
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Hi $firstName",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Semantics(
                      textField: true,
                      label: "Search for books",
                      hint: "Enter book title to search",
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for books",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // "Menu" text wrapped in a Container with _menuKey.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ExcludeSemantics(
                      child: Container(
                        key: _menuKey,
                        child: const Text(
                          "Menu",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // No additional SizedBox here—the gap is applied in the cardTop calculation.
                ],
              ),
            ),
            // Overlapping cards.
            _buildOverlappingCard(
              title: "My Library",
              subtitle: "Saved books",
              color: const Color(0xFFD9B8F3),
              position: 0,
              cardTop: effectiveCardTop,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LibraryScreen()),
                );
              },
            ),
            _buildOverlappingCard(
              title: "Explore",
              subtitle: "Explore new books",
              color: const Color(0xFFF3985B),
              position: 1,
              cardTop: effectiveCardTop,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExploreScreen()),
                );
              },
            ),
            _buildOverlappingCard(
              title: "Upload",
              subtitle: "Upload your books",
              color: const Color(0xFFDCE030),
              position: 2,
              cardTop: effectiveCardTop,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadScreen()),
                );
              },
            ),
            _buildOverlappingCard(
              title: "Settings",
              subtitle: "Change your profile settings",
              color: const Color(0xFFFF7A7B),
              position: 3,
              cardTop: effectiveCardTop,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(fullName: widget.name),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// When a search is active, we display the header and a list of search results.
  Widget _buildSearchResults(
      String firstName, List<Map<String, String>> filteredBooks) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Image(
              image: AssetImage('assets/images/logo1.png'),
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 8),
            Text(
              "Hi $firstName",
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for books",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            filteredBooks.isEmpty
                ? const Center(
              child: Text(
                "No books found.",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Semantics(
                    button: true,
                    label: "Book: ${book["title"]}",
                    excludeSemantics: true,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipOval(
                          child: Image.asset(
                            book["cover"]!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          book["title"]!,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          _showBookOptions(book);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Displays a bottom sheet with options to save or read the selected book.
  void _showBookOptions(Map<String, String> book) {
    final int bookIndex =
    books.indexWhere((b) => b["title"] == book["title"]);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                book["title"]!,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (savedBooks.contains(bookIndex)) {
                          savedBooks.remove(bookIndex);
                        } else {
                          savedBooks.add(bookIndex);
                        }
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      savedBooks.contains(bookIndex)
                          ? "Saved to Library"
                          : "Save to Library",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (bookIndex == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StoryReaderScreen()),
                        );
                      } else if (bookIndex == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const StoryReaderScreen1()),
                        );
                      } else if (bookIndex == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const StoryReaderScreen2()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Read Now"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlappingCard({
    required String title,
    required String subtitle,
    required Color color,
    required int position,
    required double cardTop,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: cardTop + (position * 150),
      left: 16,
      right: 16,
      child: Focus(
        autofocus: position == 0, // Autofocus on the first card
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: onTap,
          child: Builder(
            builder: (context) {
              return FocusableActionDetector(
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    flutterTts.speak(title); // Speak only when focus lands
                  }
                },
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward, size: 28),
                    onTap: onTap,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
