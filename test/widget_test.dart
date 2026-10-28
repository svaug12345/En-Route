// widget_test.dart — tests automatiques de l'interface (lancés par `flutter test`).
//
// Un test de widget dessine l'appli dans un faux écran, sans téléphone,
// puis vérifie que les bons textes sont affichés.

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:en_route/jeux/catalogue.dart';
import 'package:en_route/main.dart';

void main() {
  testWidgets("L'accueil affiche une tuile par jeu du catalogue", (tester) async {
    await tester.pumpWidget(const EnRouteApp());

    expect(find.text(nomAppli), findsOneWidget);
    for (final jeu in catalogue) {
      expect(find.text(jeu.nom), findsOneWidget);
    }
  });

  testWidgets("L'écran À propos affiche la version", (tester) async {
    // Pas de vrai téléphone pendant les tests : on fournit une fausse version.
    PackageInfo.setMockInitialValues(
      appName: nomAppli,
      packageName: 'com.svaug.en_route',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );

    await tester.pumpWidget(const EnRouteApp());
    await tester.tap(find.byTooltip('À propos'));
    // pumpAndSettle : attend la fin de l'animation et la réponse du Future.
    await tester.pumpAndSettle();

    expect(find.text('Version 0.1.0 (build 1)'), findsOneWidget);
  });
}
