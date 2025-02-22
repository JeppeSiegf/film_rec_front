import '../data/models.dart';

class AppState {
  List<Film> searchResults = [];
  Film? selectedFilm;
  List<Film> recommendations = [];
  bool showGrid = false;
  bool isImageMoved = false;
  bool isImageShrunk = false;
  bool isButtonDisabled = false;
}