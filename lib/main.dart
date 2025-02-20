import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart'; // Import your API service
import 'models.dart';

const Duration debounceDuration = Duration(milliseconds: 500); // Debounce duration

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static ThemeMode _themeMode = ThemeMode.system; // Default theme mode

  static void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode; // Update the theme mode
  }

  static ThemeMode get themeMode => _themeMode; // Getter for theme mode

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: MyApp.themeMode, // Use the theme mode from MyApp
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Film Recommender'), // Updated title
          actions: [
            IconButton(
              icon: Icon(
                // Change icon based on the current brightness
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Icons.wb_sunny // Sun icon for dark mode
                    : Icons.nights_stay, // Moon icon for light mode
              ),
              tooltip: MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? 'Switch to Light Mode' // Tooltip text for dark mode
                  : 'Switch to Dark Mode', // Tooltip text for light mode
              onPressed: () {
                // Change the theme mode
                final brightness = MediaQuery.of(context).platformBrightness;
                final newThemeMode = brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                MyApp.setThemeMode(newThemeMode); // Set the new theme mode
                setState(() {}); // Trigger a rebuild to apply the new theme mode
              },
            ),
          ],
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: AsyncSearchAnchor(), // Added AsyncSearchAnchor to the body
        ),
      ),
    );
  }
}

class AsyncSearchAnchor extends StatefulWidget {
  const AsyncSearchAnchor({Key? key}) : super(key: key);

  @override
  _AsyncSearchAnchorState createState() => _AsyncSearchAnchorState();
}

class _AsyncSearchAnchorState extends State<AsyncSearchAnchor> {
  String? _currentQuery; // The current query being searched for
  List<Widget> _lastOptions = []; // Suggestions received from the API
  Timer? _debounce; // Timer for debouncing API calls
  final ApiService apiService = ApiService('http://10.0.2.2:5000'); // Your API service
  bool isImageMoved = false; // To toggle image position
  bool isImageShrunk = false; // To toggle image size
  bool isButtonDisabled = false; // Disable button after one press
  List<Film> searchItems = []; // Placeholder for search items
  String selectedImageUrl = ''; // URL for selected image
  String? selectedItem; // Currently selected item
  bool showGrid = false; // Control grid visibility

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel the debounce timer on dispose
    super.dispose();
  }

  // Function to search for films from the API
  Future<List<String>?> search(String query) async {
    _currentQuery = query; // Store the current query

    // Check if the query is empty
    if (query.isEmpty) {
      return const []; // Return an empty list if the query is empty
    }

    // Call the API service to fetch film suggestions
    try {
      final List<Film> films = await apiService.searchFilms(query);
      searchItems = films; // Update the search items list
      return films.map((film) => film.title).toList(); // Return film titles as suggestions
    } catch (e) {
      print('Error fetching suggestions: $e');
      return []; // Return an empty list on error
    }
  }

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 4.0,
        ),
      ),
    ),
    child: Column(
      children: [
        SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                controller.openView(); // Open the suggestions view
              },
            );
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) async {
            // Cancel previous debounce timer if active
            if (_debounce?.isActive ?? false) _debounce?.cancel();

            // Start a new debounce timer
            _debounce = Timer(debounceDuration, () {});

            // Fetch suggestions immediately as the request returns
            final List<String>? options = await search(controller.text); // Trigger API search
            if (options != null) {
              _lastOptions = options.map((item) {
                return ListTile(
                  title: Text(item), // Display the film title
                  onTap: () {
                    debugPrint('You just selected $item');
                    setState(() {
                      selectedItem = item; // Update the selected item
                      // Reset image shrinking effect when a new item is selected
                      isImageShrunk = false;
                      isImageMoved = false; // Reset image moved status
                      isButtonDisabled = false; // Re-enable the button
                      showGrid = false; // Hide the grid when a new item is selected

                      // Get the corresponding image URL for the selected item
                      final selectedFilm = searchItems.firstWhere(
                        (film) => film.title == selectedItem,
                        orElse: () => Film(title: item, releaseYear: 0, pageRef: '', directors: [], imageRef: '') // Placeholder Film object
                      );
                      selectedImageUrl = selectedFilm.imageRef; // Set the selected image URL
                    });
                    controller.closeView(item); // Close suggestions on selection
                  },
                );
              }).toList();
            }

            // Update the state to reflect new suggestions
            setState(() {});

            return _lastOptions; // Return the latest suggestions
          },
        ),
        const SizedBox(height: 20),
       if (selectedItem != null)
  Column(
    crossAxisAlignment: CrossAxisAlignment.center, // Align children to the start
    children: [
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 500),
        firstChild: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the text
          children: [
            // Text first, image below
            Text(
              selectedItem.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
              textAlign: TextAlign.center, // Center the text
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isImageShrunk ? 66.75 : 267.0, // Adjusted size for shrinking
              height: isImageShrunk ? 100.0 : 400.0, // Adjusted size for shrinking
              alignment: Alignment.center, // Center the image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                child: Image.network(
                  selectedImageUrl.isNotEmpty
                      ? selectedImageUrl
                      : 'https://via.placeholder.com/267x400',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        secondChild: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the Row contents
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image next to the text when moved
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isImageShrunk ? 66.75 : 66.75, // Same size adjustments for the second container
              height: isImageShrunk ? 100.0 : 100.0, // Same size adjustments for the second container
              alignment: Alignment.center, // Center the image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                child: Image.network(
                  selectedImageUrl.isNotEmpty
                      ? selectedImageUrl
                      : 'https://via.placeholder.com/267x400',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedItem.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                textAlign: TextAlign.center, // Center the text in the expanded area
              ),
            ),
          ],
        ),
        crossFadeState: isImageMoved
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
      ),
    ],
  )

,
        const SizedBox(height: 20),
        // Show button only if a movie is selected
        if (selectedItem != null)
          ElevatedButton(
            onPressed: isButtonDisabled
                ? null // Disable button if already pressed
                : () {
                    setState(() {
                      isImageMoved = !isImageMoved; // Toggle image moved state
                      isImageShrunk = false; // Reset image shrink state
                      isButtonDisabled = true; // Disable button after press
                      showGrid = true; // Show grid when button is pressed
                    });
                  },
            child: const Text('Show Films'), // Button text
          ),
        const SizedBox(height: 20),
        if (showGrid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns
              crossAxisSpacing: 8.0, // Space between columns
              mainAxisSpacing: 8.0, // Space between rows
              childAspectRatio: 2 / 3, // Aspect ratio for items
            ),
            itemCount: searchItems.length, // Number of items in the grid
            itemBuilder: (context, index) {
              final Film item = searchItems[index]; // Get the current film item
              return Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      child: Image.network(
                        item.imageRef.isNotEmpty
                            ? item.imageRef
                            : 'https://via.placeholder.com/267x400', // Placeholder for the image URL
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Space between image and text
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              );
            },
          ),
      ],
    ),
  );
}
}
