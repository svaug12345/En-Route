// accueil.dart — l'écran d'accueil : une tuile par jeu du catalogue,
// et en haut à droite les boutons « Joueurs » et « À propos ».
//
// Toucher une tuile → choisir qui joue → lancer le jeu.
// Plus tard (jalon 0.9.0) : accès aux réglages.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../jeux/catalogue.dart';
import '../jeux/jeu.dart';
import '../main.dart';
import '../models/joueur.dart';
import '../services/joueurs_service.dart';
import '../theme/sv_theme.dart';
import '../widgets/avatar_joueur.dart';
import '../widgets/selection_joueurs.dart';
import 'a_propos.dart';
import 'joueurs.dart';

/// Écran d'accueil.
class Accueil extends StatelessWidget {
  const Accueil({super.key});

  /// Ouvre l'écran « À propos » par-dessus l'accueil.
  ///
  /// `Navigator.push` empile un nouvel écran ; le bouton retour du téléphone
  /// le dépile et on revient ici. `MaterialPageRoute` gère l'animation.
  void _ouvrirAPropos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const APropos()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(nomAppli),
        actions: [
          IconButton(
            tooltip: 'Joueurs',
            icon: const Icon(Icons.group_outlined),
            iconSize: 28,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EcranJoueurs()),
            ),
          ),
          IconButton(
            tooltip: 'À propos',
            icon: const Icon(Icons.info_outline),
            iconSize: 28,
            onPressed: () => _ouvrirAPropos(context),
          ),
          const SizedBox(width: SvEspace.s),
        ],
      ),
      // SafeArea : évite de dessiner sous l'encoche ou la barre de navigation.
      body: SafeArea(
        // ListView.separated : une liste qui défile, avec un espace entre chaque tuile.
        // Sur un téléphone, une seule colonne de grandes tuiles se lit mieux
        // en voiture qu'une grille serrée.
        child: ListView.separated(
          padding: const EdgeInsets.all(SvEspace.m),
          itemCount: catalogue.length + 1, // +1 pour la phrase d'introduction
          separatorBuilder: (_, _) => const SizedBox(height: SvEspace.m),
          itemBuilder: (context, index) {
            if (index == 0) {
              // Aucun joueur encore : on guide vers la création des joueurs.
              final service = context.watch<JoueursService>();
              final aucunJoueur = service.charge && service.joueurs.isEmpty;
              return Text(
                aucunJoueur
                    ? 'Commence par créer les joueurs avec le bouton en haut.'
                    : 'Choisis un jeu, puis passe le téléphone.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.sv.inkMuted,
                    ),
              );
            }
            return TuileJeu(jeu: catalogue[index - 1]);
          },
        ),
      ),
    );
  }
}

/// La tuile d'un jeu : bande de couleur à gauche, emoji, nom, nombre de
/// joueurs et règle courte. Un badge « BIENTÔT » si le jeu n'est pas prêt.
class TuileJeu extends StatelessWidget {
  const TuileJeu({super.key, required this.jeu});

  final Jeu jeu;

  /// Appui sur la tuile : on choisit les joueurs, puis on lance le jeu.
  ///
  /// Tant que le jeu n'est pas codé, on montre seulement l'ordre de passage
  /// obtenu : ça permet déjà de tester la sélection des joueurs.
  Future<void> _toucher(BuildContext context) async {
    final joueurs = await SelectionJoueurs.ouvrir(context, jeu: jeu);
    // null = retour arrière sans valider. `context.mounted` : l'écran
    // d'accueil est-il toujours là après l'attente ?
    if (joueurs == null || !context.mounted) return;

    if (jeu.disponible) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => jeu.ecran!(joueurs)),
      );
    } else {
      _montrerOrdre(context, joueurs);
    }
  }

  /// Panneau qui monte du bas de l'écran (« bottom sheet ») avec l'ordre de passage.
  void _montrerOrdre(BuildContext context, List<Joueur> joueurs) {
    final texte = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(SvEspace.l, 0, SvEspace.l, SvEspace.l),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Le panneau prend juste la hauteur nécessaire.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ordre de passage', style: texte.titleLarge),
              const SizedBox(height: SvEspace.m),
              // `indexed` donne chaque joueur avec son numéro (0, 1, 2…).
              for (final (i, joueur) in joueurs.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: SvEspace.s),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text('${i + 1}.',
                            style: const TextStyle(fontFamily: SvPolice.chiffres, fontSize: 18)),
                      ),
                      AvatarJoueur(joueur: joueur, taille: 36),
                      const SizedBox(width: SvEspace.m),
                      Text(joueur.prenom, style: texte.titleMedium),
                    ],
                  ),
                ),
              const SizedBox(height: SvEspace.s),
              Text(
                '${jeu.nom} arrive bientôt.',
                style: texte.bodyLarge?.copyWith(color: context.sv.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sv = context.sv;
    final texte = Theme.of(context).textTheme;
    final couleurJeu = jeu.couleur(sv); // La couleur d'accent, selon le thème actuel.

    return Card(
      // clipBehavior : découpe le contenu selon les coins arrondis de la carte
      // (sinon la bande de couleur dépasserait dans les coins).
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _toucher(context),
        // IntrinsicHeight : la bande de couleur prend la hauteur du contenu,
        // quelle que soit la longueur de la règle.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: couleurJeu),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SvEspace.m),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PastilleEmoji(emoji: jeu.emoji, couleur: couleurJeu),
                      const SizedBox(width: SvEspace.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(jeu.nom, style: texte.titleLarge),
                            const SizedBox(height: SvEspace.xs),
                            Wrap(
                              spacing: SvEspace.s,
                              runSpacing: SvEspace.xs,
                              children: [
                                _Badge(texte: jeu.texteJoueurs, fond: sv.tealSoft, encre: sv.ink),
                                if (!jeu.disponible)
                                  _Badge(texte: 'BIENTÔT', fond: sv.line, encre: sv.inkMuted),
                              ],
                            ),
                            const SizedBox(height: SvEspace.s),
                            Text(
                              jeu.regleCourte,
                              style: texte.bodyLarge?.copyWith(color: sv.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un rond teinté de la couleur du jeu, avec l'emoji au centre.
class _PastilleEmoji extends StatelessWidget {
  const _PastilleEmoji({required this.emoji, required this.couleur});

  final String emoji;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // withValues(alpha: 0.15) : la couleur du jeu, mais très transparente.
        color: couleur.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}

/// Petite étiquette arrondie (6 px, comme le veut la charte pour les badges).
class _Badge extends StatelessWidget {
  const _Badge({required this.texte, required this.fond, required this.encre});

  final String texte;
  final Color fond;
  final Color encre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SvEspace.s, vertical: SvEspace.xs),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(SvArrondi.badge),
      ),
      child: Text(
        texte,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: encre, letterSpacing: 0.5),
      ),
    );
  }
}
