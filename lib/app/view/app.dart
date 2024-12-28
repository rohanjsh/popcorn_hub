import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popcorn_hub/connectivity/cubit/connectivity_cubit.dart';
import 'package:popcorn_hub/l10n/l10n.dart';
import 'package:popcorn_hub/movies/cubit/movies_cubit.dart';
import 'package:popcorn_hub/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/movies/repository/movies_repository.dart';
import 'package:popcorn_hub/movies/view/movies_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MoviesRepository(Dio()),
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
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
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
