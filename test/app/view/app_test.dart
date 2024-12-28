import 'package:flutter_test/flutter_test.dart';
import 'package:popcorn_hub/app/app.dart';
import 'package:popcorn_hub/movies/view/movies_page.dart';

void main() {
  group('App', () {
    testWidgets('renders MoviesPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(MoviesPage), findsOneWidget);
    });
  });
}
