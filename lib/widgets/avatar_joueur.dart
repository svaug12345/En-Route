// avatar_joueur.dart — le rond de couleur d'un joueur, avec son emoji ou
// son initiale. Brique réutilisée partout où un joueur apparaît
// (liste des joueurs, sélection, et plus tard scores et « passe le téléphone »).

import 'package:flutter/material.dart';

import '../models/joueur.dart';
import '../theme/sv_theme.dart';

/// Rond coloré représentant un joueur.
class AvatarJoueur extends StatelessWidget {
  const AvatarJoueur({super.key, required this.joueur, this.taille = 48});

  final Joueur joueur;

  /// Diamètre du rond, en pixels.
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SvCouleursJoueurs.couleur(context, joueur.couleur),
        shape: BoxShape.circle,
      ),
      child: Text(
        joueur.avatar,
        style: TextStyle(
          // Le texte occupe environ la moitié du rond, quelle que soit sa taille.
          fontSize: taille * 0.5,
          fontWeight: FontWeight.w800,
          color: SvCouleursJoueurs.texteSur(context),
          height: 1, // Évite que l'interligne décentre l'emoji verticalement.
        ),
      ),
    );
  }
}
