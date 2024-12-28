import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

class OfflineMessage extends StatelessWidget {
  const OfflineMessage({
    required this.favorites,
    super.key,
  });
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
