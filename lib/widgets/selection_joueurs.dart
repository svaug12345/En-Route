// selection_joueurs.dart — avant une partie : cocher qui joue, parmi les
// joueurs enregistrés, et choisir si on mélange l'ordre de passage.
//
// Brique commune à tous les jeux : chaque jeu l'ouvre avec son nombre de
// joueurs minimum et maximum, et récupère la liste des joueurs dans l'ordre.
//
// Utilisation :
//   final joueurs = await SelectionJoueurs.ouvrir(context, jeu: monJeu);
//   if (joueurs != null) { ... on lance la partie ... }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ecrans/joueurs.dart';
import '../jeux/jeu.dart';
import '../models/joueur.dart';
import '../services/joueurs_service.dart';
import '../theme/sv_theme.dart';
import 'avatar_joueur.dart';

/// Écran de sélection des joueurs d'une partie.
class SelectionJoueurs extends StatefulWidget {
  const SelectionJoueurs({super.key, required this.jeu});

  /// Le jeu pour lequel on choisit les joueurs (titre, minimum, maximum).
  final Jeu jeu;

  /// Ouvre l'écran et attend le choix.
  ///
  /// Renvoie la liste des joueurs dans l'ordre de passage,
  /// ou `null` si on est revenu en arrière sans valider.
  /// `Navigator.push` renvoie un Future : il se termine quand l'écran ouvert
  /// fait `Navigator.pop(valeur)`, et donne cette valeur.
  static Future<List<Joueur>?> ouvrir(BuildContext context, {required Jeu jeu}) {
    return Navigator.of(context).push<List<Joueur>>(
      MaterialPageRoute(builder: (_) => SelectionJoueurs(jeu: jeu)),
    );
  }

  @override
  State<SelectionJoueurs> createState() => _SelectionJoueursState();
}

class _SelectionJoueursState extends State<SelectionJoueurs> {
  /// Les `id` des joueurs cochés. Un `Set` (ensemble) ne peut pas contenir
  /// deux fois la même valeur : pratique pour cocher / décocher.
  final Set<String> _coches = {};

  /// Mélanger l'ordre de passage ? Activé par défaut : c'est plus juste
  /// (ce n'est pas toujours le même qui commence).
  bool _melanger = true;

  /// Vrai tant qu'on n'a pas encore pré-coché les joueurs.
  bool _premiereFois = true;

  /// Pré-coche tout le monde s'il n'y a pas trop de joueurs.
  void _precocher(List<Joueur> joueurs) {
    if (joueurs.length <= widget.jeu.joueursMax) {
      _coches.addAll(joueurs.map((j) => j.id));
    }
  }

  /// Coche ou décoche un joueur, sans dépasser le maximum du jeu.
  void _basculer(Joueur joueur) {
    setState(() {
      if (_coches.contains(joueur.id)) {
        _coches.remove(joueur.id);
      } else if (_coches.length < widget.jeu.joueursMax) {
        _coches.add(joueur.id);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('${widget.jeu.joueursMax} joueurs au maximum pour ce jeu.'),
          ));
      }
    });
  }

  /// Valide : construit la liste dans l'ordre (mélangé ou non) et la renvoie.
  void _valider(List<Joueur> joueurs) {
    // On garde l'ordre de la liste des joueurs enregistrés…
    final choisis = joueurs.where((j) => _coches.contains(j.id)).toList();
    // … sauf si on veut mélanger. `shuffle()` mélange la liste au hasard.
    if (_melanger) choisis.shuffle();
    Navigator.of(context).pop(choisis);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<JoueursService>();
    final joueurs = service.joueurs;
    final sv = context.sv;
    final texte = Theme.of(context).textTheme;
    final jeu = widget.jeu;

    // Si un joueur a été supprimé entre-temps, on l'enlève des cochés.
    _coches.removeWhere((id) => !joueurs.any((j) => j.id == id));
    if (_premiereFois && service.charge) {
      _premiereFois = false;
      _precocher(joueurs);
    }

    final nombre = _coches.length;
    final assez = nombre >= jeu.joueursMin;

    return Scaffold(
      appBar: AppBar(title: Text(jeu.nom)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(SvEspace.m, 0, SvEspace.m, SvEspace.s),
              child: Text(
                'Qui joue ? (${jeu.texteJoueurs})',
                style: texte.titleMedium?.copyWith(color: sv.inkMuted),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: SvEspace.m),
                children: [
                  for (final joueur in joueurs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SvEspace.s),
                      child: _LigneJoueur(
                        joueur: joueur,
                        coche: _coches.contains(joueur.id),
                        onTap: () => _basculer(joueur),
                      ),
                    ),
                  // Toujours possible d'ajouter quelqu'un sans quitter l'écran.
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EcranJoueurs()),
                    ),
                    icon: const Icon(Icons.group_outlined),
                    label: Text(joueurs.isEmpty ? 'CRÉER LES JOUEURS' : 'GÉRER LES JOUEURS'),
                  ),
                  const SizedBox(height: SvEspace.m),
                ],
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: _melanger,
              onChanged: (v) => setState(() => _melanger = v),
              title: Text("Mélanger l'ordre de passage", style: texte.titleMedium),
              contentPadding: const EdgeInsets.symmetric(horizontal: SvEspace.m),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SvEspace.m, 0, SvEspace.m, SvEspace.m),
              child: Column(
                children: [
                  if (!assez)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SvEspace.s),
                      child: Text(
                        'Il faut au moins ${jeu.joueursMin} joueurs.',
                        style: texte.bodyLarge?.copyWith(color: sv.danger),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // onPressed: null → bouton grisé, impossible à toucher.
                      onPressed: assez ? () => _valider(joueurs) : null,
                      child: Text("C'EST PARTI ($nombre)"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une ligne cochable : avatar, prénom, case à cocher.
class _LigneJoueur extends StatelessWidget {
  const _LigneJoueur({required this.joueur, required this.coche, required this.onTap});

  final Joueur joueur;
  final bool coche;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sv = context.sv;
    return Material(
      // Fond « tealSoft » quand le joueur est coché : visible d'un coup d'œil.
      color: coche ? sv.tealSoft : sv.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SvArrondi.carte),
        side: BorderSide(color: coche ? sv.teal : sv.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SvEspace.m),
          child: Row(
            children: [
              AvatarJoueur(joueur: joueur),
              const SizedBox(width: SvEspace.m),
              Expanded(
                child: Text(joueur.prenom, style: Theme.of(context).textTheme.titleLarge),
              ),
              Icon(
                coche ? Icons.check_circle : Icons.radio_button_unchecked,
                color: coche ? sv.teal : sv.inkMuted,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
