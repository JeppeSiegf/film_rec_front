
class Film {
  final String pageRef;
  final String smallImageRef;
  final String largeImageRef;
  final String title;
  final int releaseYear;
  final List<String> genres;
  final List<Director> directors;
  
  

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
      genres: List<String>.from(
        (json['genres'] as List).map((genre) => genre.toString().replaceAll(RegExp(r'[<>]'), '')) // Fix in api at somepoint
      ),
      directors: (json['directors'] as List)
          .map((director) => Director(pageRef: director['page_ref'], name: director['name']))
          .toList(),
    );
}
}
class Director {
  final String pageRef;
  final String name;

  Director({required this.pageRef, required this.name});

  @override
  String toString() {
    return '$name';
  }

  factory Director.fromJson(Map<String, dynamic> json) {
    return Director(
      pageRef: json['page_ref'] as String,
      name: json['name'] as String,
    );
  }
}