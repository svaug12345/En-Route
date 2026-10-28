// joueurs_service.dart — garde la liste des joueurs et la sauvegarde
// sur le téléphone (shared_preferences), pour la retrouver à chaque lancement.
//
// C'est un `ChangeNotifier` : quand la liste change, il « prévient » tous les
// écrans qui l'écoutent (via provider), et ceux-ci se redessinent tout seuls.

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/joueur.dart';
import '../theme/sv_theme.dart';

/// Le gestionnaire des joueurs enregistrés.
class JoueursService extends ChangeNotifier {
  /// Nom de la « case » où la liste est rangée dans shared_preferences.
  static const _cle = 'joueurs';

  /// Longueur maximale d'un prénom (pour qu'il tienne en très gros à l'écran).
  static const longueurMaxPrenom = 14;

  /// La liste interne. Le `_` devant le nom la rend privée à ce fichier :
  /// les écrans ne peuvent pas la modifier directement, ils doivent passer
  /// par [ajouter], [modifier] ou [supprimer] (qui, eux, sauvegardent).
  final List<Joueur> _joueurs = [];

  /// Vrai une fois la liste chargée depuis le téléphone.
  bool _charge = false;
  bool get charge => _charge;

  /// La liste des joueurs, en lecture seule.
  UnmodifiableListView<Joueur> get joueurs => UnmodifiableListView(_joueurs);

  /// Charge les joueurs sauvegardés. Appelé une fois au démarrage.
  ///
  /// `async` / `await` : lire le stockage du téléphone prend un petit
  /// moment ; `await` attend la réponse sans bloquer l'affichage.
  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final texte = prefs.getString(_cle);
    _joueurs.clear();
    if (texte != null) {
      // try/catch : si la sauvegarde est abîmée, on repart d'une liste vide
      // plutôt que de faire planter l'appli.
      try {
        final liste = jsonDecode(texte) as List<dynamic>;
        _joueurs.addAll(liste.map((e) => Joueur.fromJson(e as Map<String, dynamic>)));
      } catch (e) {
        debugPrint('Joueurs illisibles, liste remise à zéro : $e');
      }
    }
    _charge = true;
    notifyListeners(); // « Prévenez les écrans : la liste a changé. »
  }

  /// Écrit toute la liste sur le téléphone, sous forme de texte JSON.
  Future<void> _sauvegarder() async {
    final prefs = await SharedPreferences.getInstance();
    final texte = jsonEncode(_joueurs.map((j) => j.toJson()).toList());
    await prefs.setString(_cle, texte);
  }

  /// Ajoute un nouveau joueur et le renvoie.
  Future<Joueur> ajouter({required String prenom, required int couleur, String? emoji}) async {
    final joueur = Joueur(
      // Identifiant unique : l'heure exacte en microsecondes.
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prenom: prenom.trim(),
      couleur: couleur,
      emoji: emoji,
    );
    _joueurs.add(joueur);
    notifyListeners();
    await _sauvegarder();
    return joueur;
  }

  /// Remplace un joueur existant (même `id`) par sa nouvelle version.
  Future<void> modifier(Joueur joueur) async {
    final index = _joueurs.indexWhere((j) => j.id == joueur.id);
    if (index == -1) return; // Joueur introuvable (déjà supprimé) : rien à faire.
    _joueurs[index] = joueur.copyWith(prenom: joueur.prenom.trim());
    notifyListeners();
    await _sauvegarder();
  }

  /// Supprime le joueur qui a cet `id`.
  Future<void> supprimer(String id) async {
    _joueurs.removeWhere((j) => j.id == id);
    notifyListeners();
    await _sauvegarder();
  }

  /// Vrai si un autre joueur porte déjà ce prénom (sans tenir compte des
  /// majuscules ni des espaces autour). [saufId] : le joueur qu'on est en
  /// train de modifier, qui a évidemment le droit de garder son prénom.
  bool prenomDejaPris(String prenom, {String? saufId}) {
    final cherche = prenom.trim().toLowerCase();
    return _joueurs.any((j) => j.id != saufId && j.prenom.toLowerCase() == cherche);
  }

  /// La première couleur qu'aucun joueur n'utilise encore
  /// (ou la moins utilisée si elles sont toutes prises).
  int couleurLibre() {
    final compte = List.filled(SvCouleursJoueurs.nombre, 0);
    for (final j in _joueurs) {
      compte[j.couleur % compte.length]++;
    }
    var meilleure = 0;
    for (var i = 1; i < compte.length; i++) {
      if (compte[i] < compte[meilleure]) meilleure = i;
    }
    return meilleure;
  }
}
