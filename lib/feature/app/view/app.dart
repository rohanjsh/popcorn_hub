import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popcorn_hub/core/api/api_client.dart';
import 'package:popcorn_hub/feature/connectivity/cubit/connectivity_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/movies/movies_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';
import 'package:popcorn_hub/feature/movies/view/movies_page.dart';
import 'package:popcorn_hub/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

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
