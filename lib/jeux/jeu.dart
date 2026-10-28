// jeu.dart — la « fiche » d'un jeu : tout ce que l'accueil doit savoir pour
// afficher sa tuile (nom, icône, nombre de joueurs, règle courte, couleur).
//
// Ce fichier ne contient AUCUN écran : c'est une simple description.
// La liste des jeux elle-même est dans catalogue.dart.

import 'package:flutter/widgets.dart';

import '../theme/sv_theme.dart';

/// Description d'un jeu du catalogue.
class Jeu {
  const Jeu({
    required this.id,
    required this.nom,
    required this.emoji,
    required this.joueursMin,
    required this.joueursMax,
    required this.regleCourte,
    required this.couleur,
    this.ecran,
  });

  /// Identifiant technique, sans espace ni accent (ex. `bruitage`).
  final String id;

  /// Nom affiché sur la tuile.
  final String nom;

  /// Icône du jeu (un emoji : simple, coloré, lisible par un enfant).
  final String emoji;

  /// Nombre de joueurs minimum et maximum.
  final int joueursMin;
  final int joueursMax;

  /// La règle en une phrase, affichée sous le nom.
  final String regleCourte;

  /// Couleur d'accent de la tuile, prise dans la palette SV.
  ///
  /// C'est une *fonction* qui reçoit la palette et rend une couleur, par
  /// exemple `(c) => c.blue`. Pourquoi pas directement une Color ? Parce que
  /// le bleu du thème sombre n'est pas celui du thème clair : on ne peut
  /// choisir la vraie couleur qu'au moment de dessiner, quand on connaît le thème.
  final Color Function(SvCouleurs c) couleur;

  /// Construit l'écran du jeu. `null` tant que le jeu n'est pas encore codé :
  /// la tuile s'affiche alors comme « bientôt » et n'est pas cliquable.
  final WidgetBuilder? ecran;

  /// Vrai si le jeu peut être lancé.
  bool get disponible => ecran != null;

  /// Texte « 3 à 8 joueurs » (ou « 2 joueurs et + » s'il n'y a pas vraiment de maximum).
  String get texteJoueurs =>
      joueursMax >= 99 ? '$joueursMin joueurs et +' : '$joueursMin à $joueursMax joueurs';
}
