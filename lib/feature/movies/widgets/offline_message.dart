import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

/// A widget that displays a message when the application is offline.
///
/// This widget shows different messages depending on whether there are favorite movies
/// available in the offline state:
/// * If there are no favorites, it displays both an offline message and a no favorites message
/// * If there are favorites, it only displays the offline message
///
/// Example usage:
/// ```dart
/// OfflineMessage(
///   favorites: [Movie(id: 1, title: 'Test Movie')],
/// )
/// ```
class OfflineMessage extends StatelessWidget {
  /// Creates an offline message widget.
  ///
  /// The [favorites] parameter is required and represents the list of favorite movies
  /// available offline.
  const OfflineMessage({
    required this.favorites,
    super.key,
  });

  /// The list of favorite movies available in offline mode.
  final List<Movie> favorites;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return favorites.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  l10n.offlineMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(l10n.noFavoritesOffline),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  l10n.offlineMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          );
  }
}
