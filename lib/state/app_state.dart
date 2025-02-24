import '../data/models.dart';

class AppState {
  List<Film> searchResults = [];
  Film? selectedFilm;
  Director? selectedDirector;
  List<Film> filmography = [];
  List<Film> recommendations = [];
  bool showGrid = false;
  bool isImageMoved = false;
  bool isImageShrunk = false;
  bool isButtonDisabled = false;
}