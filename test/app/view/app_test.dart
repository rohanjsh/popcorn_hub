import 'package:flutter_test/flutter_test.dart';
import 'package:popcorn_hub/feature/app/app.dart';
import 'package:popcorn_hub/feature/movies/view/movies_page.dart';

void main() {
  group('App', () {
    testWidgets('renders MoviesPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(MoviesPage), findsOneWidget);
    });
  });
}
