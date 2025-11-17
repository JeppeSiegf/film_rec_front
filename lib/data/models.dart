
class Film {
  final String pageRef;
  final String smallImageRef;
  final String largeImageRef;
  final String? bannerImageRef;
  final String title;
  final String originalTitle;
  final String description;
  final int releaseYear;
  final int runTime;
  final int popularity;
  final double? ltbxdRating;
  final double? imdbRating;
  final String? imdbRef;
  final String? seriesName;
  final int? seriesRef;
  final List<String> genres;
  final List<String> languages;
  final List<CrewMember> crewMembers;
  final List<String> roles; //Only used when fetched as part of a credit list

  Film({
    required this.pageRef,
    required this.smallImageRef,
    required this.largeImageRef,
    this.bannerImageRef,
    required this.title,
    required this.originalTitle,
    required this.description,
    required this.releaseYear,
    required this.runTime,
    required this.popularity,
    this.ltbxdRating,
    this.imdbRating,
    this.imdbRef,
    this.seriesName,
    this.seriesRef,
    required this.genres,
    required this.languages,
    required this.crewMembers,
    required this.roles,
  });

  @override
  String toString() {
    return '$title ($releaseYear)';
  }

  factory Film.fromJson(Map<String, dynamic> json) {
   
    
    return Film(
      pageRef: json['page_ref'] as String,
      smallImageRef: (json['image_ref'] as String)!,
      largeImageRef: (json['image_ref_large'] as String)!,
      bannerImageRef: json['banner_ref'] != null && (json['banner_ref'] as String).isNotEmpty
          ? (json['banner_ref'] as String)
          : null, // Handle null or empty banner_ref

      title: json['title'] as String,
      originalTitle: (json['title_original'] as String?) ?? json['title'] as String,
      description: json['description'] as String,
      releaseYear: json['release_year'] as int,
      runTime: json['runtime'] as int,
      popularity:json['total_watches'] as int,
      ltbxdRating: (json['avg_rating'] as num?)?.toDouble(),
      imdbRating: (json['imdb_rating'] as num?)?.toDouble(),
      imdbRef: json['imdb_ref'] as String?,
      seriesName: json['series'] as String?,
      seriesRef: json['series_id'] as int?,
      genres: (json['genres'] as List?)?.map((genre) => genre.toString().replaceAll(RegExp(r'[<>]'), '')).toList() ?? [],
      languages: (json['languages'] as List?)?.map((lang) => lang.toString().replaceAll(RegExp(r'[<>]'), '').split(RegExp(r'[ \(|,]'))[0]).toList() ?? [],
      crewMembers: (json['crew_members'] as List?)
          ?.map((cm) => CrewMember.fromJson(cm as Map<String, dynamic>))
          .where((member) => member.rank != null)
          .toList() 
          ?? [],
      roles: (json['roles'] as List?)?.map((role) => role.toString()).toList() ?? [],

    );
  }
}


 class SearchResult {
  final String pageRef;
  final String title;
  final int releaseYear;
  

  SearchResult({required this.title, required this.pageRef, required this.releaseYear});

  @override
  String toString() {
    return '$title ($releaseYear)';
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      pageRef: json['page_ref'] as String,
      title: json['title'] as String,
      releaseYear: json['release_year'] as int,
    );
  }
}

class CrewMember {
  final String pageRef;
  final String name;
  final String role;
  final int rank;

  CrewMember({
    required this.pageRef,
    required this.name,
    required this.role,
    required this.rank,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      pageRef: json['page_ref'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      rank: json['rank'] as int

    );
  }

  @override
  String toString() => '$name ($role)';
}

class Series {
  final String series_ref;
  final String name;
  final List<Film> films;

  Series({
    required this.series_ref,
    required this.name,
    required this.films,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      series_ref: json['page_ref'] as String,
      name: json['name'] as String,
      films: (json['films'] as List)
          .map((filmJson) => Film.fromJson(filmJson))
          .toList(),
    );
  }
}
