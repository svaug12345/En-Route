// joueurs_test.dart — tests du modèle Joueur et du JoueursService
// (sans interface : on vérifie juste la logique et la sauvegarde).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:en_route/models/joueur.dart';
import 'package:en_route/services/joueurs_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Joueur', () {
    test('se convertit en JSON et revient identique', () {
      const gaby = Joueur(id: '1', prenom: 'Gaby', couleur: 3, emoji: '🦊');
      final copie = Joueur.fromJson(gaby.toJson());
      expect(copie.prenom, 'Gaby');
      expect(copie.couleur, 3);
      expect(copie.emoji, '🦊');
    });

    test("affiche l'initiale quand il n'a pas d'emoji", () {
      const eloise = Joueur(id: '1', prenom: 'éloïse', couleur: 0);
      expect(eloise.avatar, 'É');
    });

    test("copyWith peut retirer l'emoji", () {
      const gaby = Joueur(id: '1', prenom: 'Gaby', couleur: 0, emoji: '🦊');
      expect(gaby.copyWith(retirerEmoji: true).emoji, isNull);
      expect(gaby.copyWith(prenom: 'Gab').emoji, '🦊');
    });
  });

  group('JoueursService', () {
    test('sauvegarde les joueurs et les retrouve au lancement suivant', () async {
      final service = JoueursService();
      await service.charger();
      final gaby = await service.ajouter(prenom: '  Gaby ', couleur: 0);
      await service.ajouter(prenom: 'Léo', couleur: 1);
      await service.modifier(gaby.copyWith(prenom: 'Gabrielle'));

      // Un nouveau service = comme si on relançait l'appli.
      final relance = JoueursService();
      await relance.charger();
      expect(relance.joueurs.map((j) => j.prenom), ['Gabrielle', 'Léo']);

      await relance.supprimer(gaby.id);
      expect(relance.joueurs.map((j) => j.prenom), ['Léo']);
    });

    test('repère les prénoms déjà pris, sans tenir compte des majuscules', () async {
      final service = JoueursService();
      await service.charger();
      final leo = await service.ajouter(prenom: 'Léo', couleur: 0);
      expect(service.prenomDejaPris('léo'), isTrue);
      expect(service.prenomDejaPris('Léo', saufId: leo.id), isFalse);
      expect(service.prenomDejaPris('Gaby'), isFalse);
    });

    test('propose une couleur pas encore utilisée', () async {
      final service = JoueursService();
      await service.charger();
      await service.ajouter(prenom: 'A', couleur: 0);
      await service.ajouter(prenom: 'B', couleur: 1);
      expect(service.couleurLibre(), 2);
    });

    test('une sauvegarde abîmée ne fait pas planter', () async {
      SharedPreferences.setMockInitialValues({'joueurs': 'pas du json'});
      final service = JoueursService();
      await service.charger();
      expect(service.charge, isTrue);
      expect(service.joueurs, isEmpty);
    });
  });
}
