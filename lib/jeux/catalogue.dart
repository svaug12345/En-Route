// catalogue.dart — LA liste des jeux affichés à l'accueil.
//
// Ajouter un jeu = ajouter une entrée `Jeu(...)` dans la liste ci-dessous.
// L'ordre de la liste est l'ordre des tuiles à l'écran.

import 'jeu.dart';

/// Tous les jeux de l'appli.
///
/// Pour l'instant (v0.1.0) aucun jeu n'a d'écran (`ecran` absent) :
/// les tuiles sont visibles mais inactives.
final List<Jeu> catalogue = [
  Jeu(
    id: 'espion',
    nom: "L'Espion du trajet",
    emoji: '🕵️',
    joueursMin: 3,
    joueursMax: 8,
    regleCourte: "Un espion se cache parmi vous. Démasque-le avant qu'il trouve le lieu.",
    couleur: (c) => c.blue,
  ),
  Jeu(
    id: 'mots_interdits',
    nom: 'Trois mots interdits',
    emoji: '🤐',
    joueursMin: 2,
    joueursMax: 8,
    regleCourte: 'Fais deviner le mot sans dire les trois mots interdits.',
    couleur: (c) => c.danger,
  ),
  Jeu(
    id: 'bruitage',
    nom: 'Bruitage',
    emoji: '🔊',
    joueursMin: 2,
    joueursMax: 99, // Pas de vraie limite : toute la voiture peut jouer.
    regleCourte: 'Fais deviner la carte avec des bruits. Pas un seul mot.',
    couleur: (c) => c.teal,
  ),
];
