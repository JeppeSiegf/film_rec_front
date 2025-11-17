import '../data/models.dart';

class AppState {
  List<SearchResult> searchResults = [];
  Film? selectedFilm;
  CrewMember? selectedDirector;
  List<Film> filmography = [];
  List<Film> recommendations = [];
  bool showGrid = false;
  bool isImageMoved = false;
  bool isImageShrunk = false;
  bool isButtonDisabled = false;
  bool isLoading = false;

}