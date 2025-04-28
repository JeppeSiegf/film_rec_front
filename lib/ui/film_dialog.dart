// file: film_popup.dart
import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/crew_dialog.dart';
import 'package:film_rec_front/utils/base_dialog.dart';
import 'package:film_rec_front/utils/credit_list.dart';
import 'package:film_rec_front/utils/poster_diplay.dart';
import 'package:film_rec_front/utils/runtime_converter.dart';
import 'package:film_rec_front/utils/tag_list.dart';
import 'package:film_rec_front/utils/title_display.dart';
import 'package:flutter/material.dart';

void showFilmPopup(BuildContext context, Film film, void Function(String) onFilmSelected) {
  final apiService = ApiService();
  showAppPopup(
    context: context,
    builder: (context) => BasePopupDialog(
      child: FilmPopupContent(film: film, onFilmSelected: onFilmSelected, apiService: apiService),
    ),
  );
}

class FilmPopupContent extends StatefulWidget {
  final Film film;
  final ApiService apiService;
  final void Function(String) onFilmSelected;

  const FilmPopupContent({
    Key? key,
    required this.film,
    required this.apiService,
    required this.onFilmSelected,
  }) : super(key: key);
  
  @override
  State<FilmPopupContent> createState() => _FilmPopupContentState();
}

class _FilmPopupContentState extends State<FilmPopupContent>
    with TickerProviderStateMixin {
  Film? _film;
  bool _isLoading = true;
  String? _error;
  static const int _collapsedMaxRows = 5;
  
  // Map to track expanded roles
  final Map<String, bool> _expandedRoles = {};
  
  @override
  void initState() {
    super.initState();
    if (widget.film.crewMembers.isNotEmpty) {
      _setupFilm(widget.film);
    } else {
      _fetchFilm();
    }
  }
  
  void _setupFilm(Film film) {
    // Initialize expanded state for all roles to false
    for (var member in film.crewMembers) {
      if (member.role.isNotEmpty && !_expandedRoles.containsKey(member.role.toLowerCase())) {
        _expandedRoles[member.role.toLowerCase()] = false;
      }
    }
    
    setState(() {
      _film = film;
      _isLoading = false;
    });
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
  imageUrl: (film.bannerImageRef != null && film.bannerImageRef!.isNotEmpty)
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
                titleStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 25,
                  
                ),
                includeYear: false
              ),
              const SizedBox(height: 8),
              CrewListUtils.buildCrewList(
                crewMembers: film.crewMembers,
                role: 'director',
                startText: 'by:',
                context: context,
                maxWidth: 300,
                maxRows: 10,
                onCrewTapped: (member, role) =>
                    showCrewPopup(context, member, role, widget.onFilmSelected),
                endText: '...',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                ),
                textAlign: TextAlign.center
 
              ),
               const SizedBox(height: 8),
               Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   Text(
                      '${film.releaseYear}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                    if (film.title != film.originalTitle) ...[
                      const SizedBox(width: 4),
                      const Text('|', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      MovieTextUtils.buildMovieTitle(
                        film: film,
                        context: context,
                        includeYear: false,
                        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                        useOppositeLanguage: true,
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Text('|', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                     RunTimeConverter.buildRuntimeText(
                      film.runTime,
                      context: context,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
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
          ),
        
        
      ],
    ),
  ),
),
      const Divider(thickness: 1, height: 20),
      _buildActionFooter(
        context,
        onPressed: () {
          widget.onFilmSelected(film.pageRef);
          Navigator.of(context).popUntil((r) => r.isFirst);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}