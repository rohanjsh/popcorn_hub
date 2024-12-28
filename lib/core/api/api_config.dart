// ignore_for_file: lines_longer_than_80_chars

class ApiConfig {
  const ApiConfig._();
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String authKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNzYwZjdjMDRhMDNmZDc0ODlhMmExODczNDNjODJmMCIsIm5iZiI6MTYzMzU4ODIwMy45MzkwMDAxLCJzdWIiOiI2MTVlOTNlYmQxNDQ0MzAwNjAzMDQyY2UiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.LZnwIow7OZ8LzluutBuCgpglGUOgKk0lN9LFM83V5c8';

  static const String trendingMovies = '/trending/movie/day';
  static const String searchMovies = '/search/movie';

  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String imageOriginalBaseUrl =
      'https://image.tmdb.org/t/p/original';
}
