
class Film {
  final String pageRef;
  final String smallImageRef;
  final String largeImageRef;
  final  String title;
  final int releaseYear;
  final List<String> genres;
  final List<String> directors;
  
  

  Film({required this.title, 
        required this.releaseYear, 
        required this.smallImageRef,
        required this.largeImageRef,
        required this.pageRef,
        required this.genres,
        required this.directors,});

  @override
  String toString() {
    return '$title ($releaseYear)';
  }

 

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      pageRef: json['page_ref'] as String,
      smallImageRef: json['image_ref'] as String,
      largeImageRef: json['image_ref_large'] as String,
      title: json['title'] as String,
      releaseYear: json['release_year'] as int,
      genres: List<String>.from(json['genres']),
      directors: List<String>.from(json['directors']),
    );
}
}