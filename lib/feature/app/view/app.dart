import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popcorn_hub/core/api/api_client.dart';
import 'package:popcorn_hub/feature/connectivity/cubit/connectivity_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/movies/movies_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';
import 'package:popcorn_hub/feature/movies/view/movies_page.dart';
import 'package:popcorn_hub/l10n/l10n.dart';

/// {@template app}
/// The root widget of the PopcornHub application.
///
/// This widget sets up the application's dependency injection, state management,
/// and theme configuration. It provides:
/// * [MoviesRepository] as a repository provider
/// * [ConnectivityCubit], [MoviesCubit], and [SearchCubit] as BLoC providers
/// * Material theme configuration
/// * Localization support
///
/// Example usage:
/// ```dart
/// void main() {
///   runApp(const App());
/// }
/// ```
///
/// The widget tree structure:
/// ```md
/// App
/// └── RepositoryProvider<MoviesRepository>
///     └── MultiBlocProvider
///         ├── ConnectivityCubit
///         ├── MoviesCubit
///         └── SearchCubit
///             └── MaterialApp
///                 └── MoviesPage
/// ```
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  ///
  /// Creates a new instance of [App].
  ///
  /// The [key] parameter is optional and is passed to the superclass.
  const App({super.key});

  /// Builds the widget tree for the application.
  ///
  /// This method sets up the following:
  /// * Dependency injection for repositories and cubits
  /// * Material theme with dark mode
  /// * Localization support
  /// * Initial route to [MoviesPage]
  ///
  /// Returns a widget tree with all necessary providers and configuration.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MoviesRepository(ApiClient()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConnectivityCubit(),
          ),
          BlocProvider(
            create: (context) => MoviesCubit(
              context.read<MoviesRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SearchCubit(
              context.read<MoviesRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MoviesPage(),
        ),
      ),
    );
  }
}
