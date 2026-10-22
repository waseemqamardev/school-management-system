import 'package:flutter_test/flutter_test.dart';
import 'package:darearqam_school/main.dart';
import 'package:darearqam_school/services/repository_manager.dart';

void main() {
  testWidgets('Dar-e-Arqam app smoke test', (WidgetTester tester) async {
    final repoMgr = RepositoryManager();
    await repoMgr.initialize();

    await tester.pumpWidget(DarEArqamApp(repoManager: repoMgr));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Dar-e-Arqam'), findsWidgets);
  });
}
