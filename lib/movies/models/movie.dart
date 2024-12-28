class Movie {
  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    this.isFavorite = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      posterPath: json['poster_path'] as String,
      overview: json['overview'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  bool isFavorite;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'overview': overview,
        'isFavorite': isFavorite,
      };
}
