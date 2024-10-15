class Film {
  final  String title;
  final int releaseyear;
  final String imageUrl;

  Film({required this.title, required this.releaseyear, required this.imageUrl});

  @override
  String toString() {
    return '$title ($releaseyear)';
  }
}