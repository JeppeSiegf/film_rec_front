// file: film_popup.dart
import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/crew_dialog.dart';
import 'package:film_rec_front/ui/ratings_display.dart';
import 'package:film_rec_front/ui/rec_grid.dart';
import 'package:film_rec_front/utils/base_dialog.dart';
import 'package:film_rec_front/utils/credit_list.dart';
import 'package:film_rec_front/utils/poster_diplay.dart';
import 'package:film_rec_front/utils/runtime_converter.dart';
import 'package:film_rec_front/utils/tag_list.dart';
import 'package:film_rec_front/utils/title_display.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showFilmPopup(
    BuildContext context, Film film, void Function(String) onFilmSelected) {
  final apiService = ApiService();
  showAppPopup(
    context: context,
    builder: (context) => BasePopupDialog(
      child: FilmPopupContent(
          film: film, onFilmSelected: onFilmSelected, apiService: apiService),
    ),
  );
}

class FilmPopupContent extends StatefulWidget {
  final Film film;
  final List<Film> filmseries;
  final ApiService apiService;
  final void Function(String) onFilmSelected;

  const FilmPopupContent({
    Key? key,
    required this.film,
    this.filmseries = const [],
    required this.apiService,
    required this.onFilmSelected,
  }) : super(key: key);

  @override
  State<FilmPopupContent> createState() => _FilmPopupContentState();
}

class _FilmPopupContentState extends State<FilmPopupContent>
    with TickerProviderStateMixin {
  Film? _film;
  List<Film> filmseries = [];
  bool _isLoading = true;
  String? _error;
  static const int _collapsedMaxRows = 5;

  // Map to track expanded roles
  final Map<String, bool> _expandedRoles = {};

  // State for role section expansion
  bool _showAllRoles = false;

  @override
  void initState() {
    super.initState();
    if (widget.film.crewMembers.isNotEmpty) {
      _setupFilm(widget.film);
    } else {
      _fetchFilm();
    }
  }

  void _setupFilm(Film film) async {
    // Initialize expanded state for all roles to false
    for (var member in film.crewMembers) {
      if (member.role.isNotEmpty &&
          !_expandedRoles.containsKey(member.role.toLowerCase())) {
        _expandedRoles[member.role.toLowerCase()] = false;
      }
    }

    setState(() {
      _film = film;
      _isLoading = false;
    });

    if (film.seriesRef != null) {
      try {
        final seriesFilms =
            await widget.apiService.getFilmSeries(film.seriesRef!);
        setState(() {
          filmseries = seriesFilms; // <-- update state so UI rebuilds
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _fetchFilm() async {
    setState(() => _isLoading = true);
    try {
      final film = await widget.apiService.getFilm(widget.film.pageRef);
      _setupFilm(film);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded(String role) {
    setState(() {
      _expandedRoles[role] = !(_expandedRoles[role] ?? false);
    });
  }

  void _toggleShowAllRoles() {
    setState(() {
      _showAllRoles = !_showAllRoles;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    final film = _film!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                FilmBannerImage(
                  imageUrl: (film.bannerImageRef != null &&
                          film.bannerImageRef!.isNotEmpty)
                      ? film.bannerImageRef!
                      : 'lib/assets/banner_fallback.jpg',
                ),

                // Title and Director
                Center(
                  child: Column(
                    children: [
                      MovieTextUtils.buildMovieTitle(
                          film: film,
                          context: context,
                          textAlign: TextAlign.center,
                          titleStyle: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontSize: 25,
                              ),
                          includeYear: false),
                      const SizedBox(height: 8),
                      CrewListUtils.buildCrewList(
                          crewMembers: film.crewMembers,
                          role: 'director',
                          startText: 'by:',
                          context: context,
                          maxWidth: 300,
                          maxRows: 10,
                          onCrewTapped: (member, role) => showCrewPopup(
                              context, member, role, widget.onFilmSelected),
                          endText: '...',
                          textStyle:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${film.releaseYear}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 12),
                          ),
                          if (film.title != film.originalTitle) ...[
                            const SizedBox(width: 4),
                            const Text('|', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            MovieTextUtils.buildMovieTitle(
                              film: film,
                              context: context,
                              includeYear: false,
                              titleStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 12),
                              useOppositeLanguage: true,
                            ),
                          ],
                          const SizedBox(width: 4),
                          const Text('|', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          RunTimeConverter.buildRuntimeText(
                            film.runTime,
                            context: context,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        film.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      if (film.genres.isNotEmpty)
                        TagListUtils.buildTagList(
                          context: context,
                          tags: film.genres,
                        ),
                      const SizedBox(height: 10),
                      if (film.languages.isNotEmpty)
                        TagListUtils.buildTagList(
                          context: context,
                          tags: film.languages,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                if (film.ltbxdRating != null || film.imdbRating != null)
                  const Divider(thickness: 1, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (film.imdbRating != null)
                      RatingsDisplay(
                        rating: film.imdbRating!,
                        maxRating: 10,
                        serviceName: 'IMDb',
                         onServiceTap: () => launchUrl(Uri.parse('https://www.imdb.com/title/${film.imdbRef}/'))
                      ),
                    if (film.ltbxdRating != null)
                      RatingsDisplay(
                        rating: film.ltbxdRating!,
                        maxRating: 5,
                        serviceName: 'Letterboxd',
                        starColor: Color(0xFF00E054),
                        onServiceTap: () => launchUrl(Uri.parse('https://letterboxd.com/film/${film.pageRef}')),
                      ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(thickness: 1, height: 20),

                // Crew
                if (film.crewMembers.isNotEmpty)
                  CrewListUtils.buildCreditLists(
                    context,
                    film,
                    _expandedRoles,
                    _collapsedMaxRows,
                    widget.onFilmSelected,
                    _toggleExpanded,
                    showAllRoles: _showAllRoles,
                    toggleShowAllRoles: _toggleShowAllRoles,
                  ),

                // Add some spacing at the bottom
                const SizedBox(height: 6),

                if (film.seriesRef != null) ...[
                  Divider(thickness: 1, height: 6),
                  SizedBox(
                    // optional, or remove if you want dynamic
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Part of...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            formatSeriesName(widget.film.seriesName),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RecommendationsGrid(
                    films: filmseries,
                    onFilmSelected: widget.onFilmSelected,
                  ),
                ],
              ],
            ),
          ),
        ),
        const Divider(thickness: 1, height: 20),
        _buildActionFooter(
          context,
          onPressed: () {
            widget.onFilmSelected(film.pageRef);
            Navigator.of(context).pop();
          },
          icon: Icons.movie_filter,
        ),
      ],
    );
  }

  Widget _buildActionFooter(BuildContext context,
      {required VoidCallback onPressed, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        label: Icon(icon),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  String formatSeriesName(String? name) {
  if (name == null) return '';

    // Replace Collection med Series
    String result = name.contains('Collection')
        ? name.replaceAll('Collection', 'Series')
        : name;

    // Add a "The " only if it doesn't already start with it
    List<String> prefixes = ['The ', 'A ', 'An '];
    if (!prefixes.any((prefix) => result.trimLeft().startsWith(prefix))) {
      result = 'The $result';
    }

    return result;
}
}
