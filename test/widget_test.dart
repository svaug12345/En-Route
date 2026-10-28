// widget_test.dart — tests automatiques de l'interface (lancés par `flutter test`).
//
// Un test de widget dessine l'appli dans un faux écran, sans téléphone,
// puis vérifie que les bons textes sont affichés.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:en_route/jeux/catalogue.dart';
import 'package:en_route/main.dart';
import 'package:en_route/services/joueurs_service.dart';

/// L'appli complète, avec son service de joueurs (comme dans main()).
Widget _appli() => ChangeNotifierProvider(
      create: (_) => JoueursService()..charger(),
      child: const EnRouteApp(),
    );

/// Faux joueurs déjà sauvegardés sur le « téléphone » de test.
void _joueursSauvegardes(List<String> prenoms) {
  SharedPreferences.setMockInitialValues({
    'joueurs': jsonEncode([
      for (final (i, p) in prenoms.indexed) {'id': 'j$i', 'prenom': p, 'couleur': i},
    ]),
  });
}

void main() {
  // Avant chaque test : un stockage vide (aucun joueur).
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets("L'accueil affiche une tuile par jeu du catalogue", (tester) async {
    await tester.pumpWidget(_appli());
    await tester.pumpAndSettle();

    expect(find.text(nomAppli), findsOneWidget);
    for (final jeu in catalogue) {
      expect(find.text(jeu.nom), findsOneWidget);
    }
    expect(find.textContaining('Commence par créer les joueurs'), findsOneWidget);
  });

  testWidgets("L'écran À propos affiche la version", (tester) async {
    // Pas de vrai téléphone pendant les tests : on fournit une fausse version.
    PackageInfo.setMockInitialValues(
      appName: nomAppli,
      packageName: 'com.svaug.en_route',
      version: '0.2.0',
      buildNumber: '2',
      buildSignature: '',
    );

    await tester.pumpWidget(_appli());
    await tester.tap(find.byTooltip('À propos'));
    // pumpAndSettle : attend la fin de l'animation et la réponse du Future.
    await tester.pumpAndSettle();

    expect(find.text('Version 0.2.0 (build 2)'), findsOneWidget);
  });

  testWidgets('On crée un joueur depuis l\'écran Joueurs', (tester) async {
    await tester.pumpWidget(_appli());
    await tester.tap(find.byTooltip('Joueurs'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pas encore de joueur'), findsOneWidget);

    await tester.tap(find.text('AJOUTER UN JOUEUR'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Gaby');
    await tester.tap(find.text('ENREGISTRER'));
    await tester.pumpAndSettle();

    // De retour sur la liste, Gaby y est.
    expect(find.text('Gaby'), findsOneWidget);
  });

  testWidgets('La sélection exige le minimum de joueurs du jeu', (tester) async {
    _joueursSauvegardes(['Gaby', 'Léo']); // 2 joueurs, l'Espion en demande 3
    await tester.pumpWidget(_appli());
    await tester.pumpAndSettle();

    await tester.tap(find.text("L'Espion du trajet"));
    await tester.pumpAndSettle();

    expect(find.text('Il faut au moins 3 joueurs.'), findsOneWidget);
    // Le bouton est désactivé : onPressed vaut null.
    final bouton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, "C'EST PARTI (2)"));
    expect(bouton.onPressed, isNull);
  });

  testWidgets("Valider la sélection montre l'ordre de passage", (tester) async {
    _joueursSauvegardes(['Gaby', 'Léo']);
    await tester.pumpWidget(_appli());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bruitage'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("C'EST PARTI (2)"));
    await tester.pumpAndSettle();

    expect(find.text('Ordre de passage'), findsOneWidget);
    expect(find.text('Bruitage arrive bientôt.'), findsOneWidget);
  });
}
