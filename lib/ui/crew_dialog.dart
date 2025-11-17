import 'dart:async';

import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/utils/dialog_dropdown.dart';
import 'package:film_rec_front/ui/rec_grid.dart';
import 'package:film_rec_front/utils/base_dialog.dart';
import 'package:film_rec_front/utils/dropdown_lists.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';

void showCrewPopup(
    BuildContext context, CrewMember crewMember, String crewRole, void Function(String) onFilmSelected) {
  final apiService = ApiService();
  
  showAppPopup(
    context: context,
    builder: (context) => BasePopupDialog(
      child: CrewPopupContent(
        crewMember: crewMember, 
        startRole: crewRole, 
        onFilmSelected: onFilmSelected, 
        apiService: apiService,
      ),
    ),
  );
}



class CrewPopupContent extends StatefulWidget {
  final CrewMember crewMember;
  final String startRole;
  final void Function(String) onFilmSelected;
  final ApiService apiService;

  const CrewPopupContent({
    Key? key, 
    required this.crewMember, 
    required this.startRole, 
    required this.onFilmSelected, 
    required this.apiService,
  }) : super(key: key);

  @override
  _CrewPopupContentState createState() => _CrewPopupContentState();
}

class _CrewPopupContentState extends State<CrewPopupContent> {
  late Future<List<Film>> _filmFuture;
  Set<String> _availableRoles = {};
  List<String> _sortedRoles = [];
  Map<String, int> _roleFrequency = {};
  String? _selectedRole = '';
  String _selectedSortOption = "Popularity";
  bool _isLoading = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _fetchFilms();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
    
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _fetchFilms() {
    _showLoading();
    
    _filmFuture = widget.apiService.getFilmography(widget.crewMember.pageRef).then((films) {
      Map<String, int> roleCount = {};
      Set<String> roles = {};
      
      for (var film in films) {
        for (var role in film.roles) {
          roles.add(role);
          roleCount[role] = (roleCount[role] ?? 0) + 1;
        }
      }

      List<String> sortedRoles = roles.toList()
        ..sort((a, b) => (roleCount[b] ?? 0).compareTo(roleCount[a] ?? 0));

      if (mounted) {
        setState(() {
          _availableRoles = roles;
          _sortedRoles = sortedRoles;
          _roleFrequency = roleCount;
          _selectedRole = widget.startRole;
        });
      }

      return films;
    });
  }

  void _updateGrid(String newRole) {
    _showLoading();
    setState(() {
      _selectedRole = newRole;
    });
  }

  void _sortFilms(String sortOption) {
    _showLoading();
    setState(() {
      _selectedSortOption = sortOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        _buildHeader(context),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Film>>(
            future: _filmFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No films found.'));
              } else {
                List<Film> filteredFilms = snapshot.data!
                    .where((film) => film.roles.contains(_selectedRole))
                    .toList();

                _applySort(filteredFilms);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: RecommendationsGrid(
                    films: filteredFilms,
                    onFilmSelected: widget.onFilmSelected,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _applySort(List<Film> films) {
    switch (_selectedSortOption) {
      case "Alphabetical":
        films.sort((a, b) => a.title.compareTo(b.title));
        break;
      case "Rating":
        films.sort((a, b) => b.ltbxdRating!.compareTo(a.ltbxdRating!));
        break;
      case "Release Year":
        films.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
        break;
      
      case "Popularity":
      default:
        films.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            widget.crewMember.name,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          right: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_availableRoles.isNotEmpty)
                CustomDropdown<String>(
                  items: _sortedRoles,
                  iconMap: roleIcons,
                  selectedItem: _selectedRole!,
                  onItemSelected: _updateGrid,
                ),
              const SizedBox(width: 2),
              CustomDropdown<String>(
                items: const ['Popularity', "Alphabetical","Rating", "Release Year"],
                iconMap: sortingIcons,
                selectedItem: _selectedSortOption,
                onItemSelected: _sortFilms,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
