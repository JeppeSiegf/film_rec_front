import 'package:flutter/material.dart';
import 'package:film_rec_front/models.dart';

void main() => runApp(const SearchBarApp());

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false; // Dark mode toggle
  Film? selectedItem; // Variable to hold the selected item
  String selectedImageUrl =
      ''; // Variable to hold the URL of the image to display
  bool isImageShrunk = false; // Variable to track if image is shrunk
  bool isImageMoved = false;
  int imageCount = 0;
  int maxImages = 15;
  bool isButtonDisabled = false; // To track if the button is disabled

  final List<Film> searchItems = [
    Film(
      title: 'Pulp Fiction',
      releaseyear: 1994,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/1/4/4/4/51444-pulp-fiction-0-2000-0-3000-crop.jpg?v=dee19a8077',
    ),
    Film(
      title: 'Goodfellas',
      releaseyear: 1994,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/1/3/8/3/51383-goodfellas-0-2000-0-3000-crop.jpg?v=c6c265f228',
    ),
    Film(
      title: 'Megalpolis',
      releaseyear: 2024,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/2/0/3/2/8/520328-megalopolis-0-2000-0-3000-crop.jpg?v=64ab4fa858',
    ),
    Film(
      title: 'Pulp Fiction',
      releaseyear: 1994,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/1/4/4/4/51444-pulp-fiction-0-2000-0-3000-crop.jpg?v=dee19a8077',
    ),
    Film(
      title: 'Goodfellas',
      releaseyear: 1994,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/1/3/8/3/51383-goodfellas-0-2000-0-3000-crop.jpg?v=c6c265f228',
    ),
    Film(
      title: 'Megapolis',
      releaseyear: 2024,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/2/0/3/2/8/520328-megalopolis-0-2000-0-3000-crop.jpg?v=64ab4fa858',
    ),
    Film(
      title: 'Pulp Fiction',
      releaseyear: 1994,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/1/4/4/4/51444-pulp-fiction-0-2000-0-3000-crop.jpg?v=dee19a8077',
    ),
    Film(
      title: 'Goodfellas',
      releaseyear: 1994,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/1/3/8/3/51383-goodfellas-0-2000-0-3000-crop.jpg?v=c6c265f228',
    ),
    Film(
      title: 'Megapolis',
      releaseyear: 2024,
      imageUrl:
          'https://a.ltrbxd.com/resized/film-poster/5/2/0/3/2/8/520328-megalopolis-0-2000-0-3000-crop.jpg?v=64ab4fa858',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Film Recommender'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: () {
                setState(() {
                  isDark = !isDark; // Toggle dark mode
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          // Make the entire body scrollable
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(searchItems.length,
                      (int index) {
                    final Film item = searchItems[index];
                    return ListTile(
                      title: Text(item.title),
                      onTap: () {
                        setState(() {
                          selectedItem = item;
                          selectedImageUrl =
                              item.imageUrl; // Use the model's image URL
                          isImageShrunk = false;
                          isImageMoved = false; // Reset image movement
                          imageCount = 0; // Reset the image grid
                          isButtonDisabled =
                              false; // Re-enable button if it was disabled
                          controller.closeView(item.toString());
                        });
                      },
                    );
                  });
                },
              ),
              const SizedBox(height: 20),
              if (selectedItem != null)
                Column(
                  children: [
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 500),
                      firstChild: Column(
                        children: [
                          // Text first, image below
                          Text(
                            selectedItem.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : Colors
                                          .black, // Match text color with AppBar
                                ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isImageShrunk ? 50.0 : 267.0,
                            height: isImageShrunk ? 50.0 : 400.0,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                              child: Image.network(
                                selectedImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      secondChild: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image next to the text when moved
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isImageShrunk ? 66.75 : 267.0,
                            height: isImageShrunk ? 100.0 : 400.0,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                              child: Image.network(
                                selectedImageUrl,
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
                                      color:
                                          isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ),
                      crossFadeState: isImageMoved
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                    const SizedBox(height: 20),
                    // Button to move and shrink the image
                    // Button to move and shrink the image
                    ElevatedButton(
                      onPressed: isButtonDisabled
                          ? null
                          : () {
                              setState(() {
                                isImageShrunk = !isImageShrunk;
                                isImageMoved = true;
                                if (imageCount < maxImages) {
                                  imageCount = 9;
                                }
                                isButtonDisabled = true;
                              });
                            },
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.movie_creation),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                     LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 5;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: imageCount,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.7, // Adjusted aspect ratio for better visuals
                            crossAxisSpacing: 8, // Space between columns
                            mainAxisSpacing: 8, // Space between rows
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final Film item = searchItems[index % searchItems.length]; // Reuse items for testing
                            return Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                    child: Image.network(
                                      item.imageUrl,
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
                                      color:
                                          isDark ? Colors.white : Colors.black),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}