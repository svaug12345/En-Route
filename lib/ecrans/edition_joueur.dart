// edition_joueur.dart — créer ou modifier un joueur : prénom, couleur, avatar.
// En modification, on peut aussi supprimer le joueur (avec confirmation).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/joueur.dart';
import '../services/joueurs_service.dart';
import '../theme/sv_theme.dart';
import '../widgets/avatar_joueur.dart';

/// Les avatars proposés. `null` = afficher l'initiale du prénom.
const List<String?> _emojisProposes = [
  null, '🦊', '🐼', '🐸', '🦁', '🐯', '🐨', '🐙', '🦄',
  '🐢', '🐝', '🐧', '🚗', '🚀', '⚽', '🎸', '🌟', '🍕',
];

/// Écran de création (idJoueur == null) ou de modification d'un joueur.
///
/// C'est un `StatefulWidget` : contrairement aux écrans précédents, il garde
/// des données qui changent pendant qu'on l'utilise (le prénom tapé, la
/// couleur cochée…). Ces données vivent dans la classe `_EditionJoueurState`.
class EditionJoueur extends StatefulWidget {
  const EditionJoueur({super.key, this.idJoueur});

  final String? idJoueur;

  @override
  State<EditionJoueur> createState() => _EditionJoueurState();
}

class _EditionJoueurState extends State<EditionJoueur> {
  /// Le contrôleur garde le texte du champ « Prénom » et permet de le lire.
  final _prenom = TextEditingController();

  late int _couleur;
  String? _emoji;

  /// Message d'erreur sous le champ prénom (null = pas d'erreur).
  String? _erreur;

  /// Le joueur en cours de modification (null en création).
  Joueur? _original;

  bool get _creation => widget.idJoueur == null;

  /// `initState` est appelé une seule fois, quand l'écran apparaît :
  /// c'est là qu'on pré-remplit les champs.
  @override
  void initState() {
    super.initState();
    // context.read : lire le service UNE fois, sans écouter ses changements
    // (on n'a pas besoin de redessiner ce formulaire si la liste bouge).
    final service = context.read<JoueursService>();
    _original = service.joueurs.where((j) => j.id == widget.idJoueur).firstOrNull;
    if (_original != null) {
      _prenom.text = _original!.prenom;
      _couleur = _original!.couleur;
      _emoji = _original!.emoji;
    } else {
      _couleur = service.couleurLibre();
    }
    // À chaque lettre tapée, on redessine (pour mettre à jour l'aperçu de l'avatar).
    _prenom.addListener(() => setState(() => _erreur = null));
  }

  /// `dispose` est appelé quand l'écran disparaît : on libère le contrôleur.
  @override
  void dispose() {
    _prenom.dispose();
    super.dispose();
  }

  /// Vérifie le formulaire puis enregistre et revient à la liste.
  Future<void> _enregistrer() async {
    final service = context.read<JoueursService>();
    final prenom = _prenom.text.trim();

    if (prenom.isEmpty) {
      setState(() => _erreur = 'Écris un prénom.');
      return;
    }
    if (service.prenomDejaPris(prenom, saufId: widget.idJoueur)) {
      setState(() => _erreur = 'Ce prénom est déjà pris.');
      return;
    }

    if (_original == null) {
      await service.ajouter(prenom: prenom, couleur: _couleur, emoji: _emoji);
    } else {
      await service.modifier(_original!.copyWith(
        prenom: prenom,
        couleur: _couleur,
        emoji: _emoji,
        retirerEmoji: _emoji == null,
      ));
    }
    // `mounted` : l'écran est-il toujours affiché ? Après un `await`, on vérifie
    // toujours avant d'utiliser le context (l'utilisateur a pu quitter l'écran).
    if (mounted) Navigator.of(context).pop();
  }

  /// Demande confirmation, puis supprime le joueur.
  Future<void> _supprimer() async {
    // showDialog ouvre une fenêtre par-dessus l'écran et attend la réponse :
    // true si on appuie sur « Supprimer », false/null sinon.
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${_original!.prenom} ?'),
        content: const Text('Ce joueur disparaîtra de tous les jeux.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.sv.danger),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;
    await context.read<JoueursService>().supprimer(_original!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sv = context.sv;
    final texte = Theme.of(context).textTheme;

    // Un joueur « brouillon » construit à partir du formulaire, juste pour l'aperçu.
    final apercu = Joueur(id: '', prenom: _prenom.text.trim(), couleur: _couleur, emoji: _emoji);

    return Scaffold(
      appBar: AppBar(
        title: Text(_creation ? 'Nouveau joueur' : 'Modifier'),
        actions: [
          if (!_creation)
            IconButton(
              tooltip: 'Supprimer',
              icon: Icon(Icons.delete_outline, color: sv.danger),
              iconSize: 28,
              onPressed: _supprimer,
            ),
          const SizedBox(width: SvEspace.s),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SvEspace.m),
                children: [
                  Center(child: AvatarJoueur(joueur: apercu, taille: 96)),
                  const SizedBox(height: SvEspace.l),
                  TextField(
                    controller: _prenom,
                    autofocus: _creation, // Le clavier s'ouvre directement en création.
                    textCapitalization: TextCapitalization.words,
                    maxLength: JoueursService.longueurMaxPrenom,
                    style: texte.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      errorText: _erreur,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SvArrondi.carte),
                      ),
                    ),
                    onSubmitted: (_) => _enregistrer(),
                  ),
                  const SizedBox(height: SvEspace.m),
                  Text('Couleur', style: texte.titleMedium),
                  const SizedBox(height: SvEspace.s),
                  Wrap(
                    spacing: SvEspace.s,
                    runSpacing: SvEspace.s,
                    children: [
                      for (var i = 0; i < SvCouleursJoueurs.nombre; i++)
                        _PastilleCouleur(
                          couleur: SvCouleursJoueurs.couleur(context, i),
                          nom: SvCouleursJoueurs.noms[i],
                          choisie: i == _couleur,
                          onTap: () => setState(() => _couleur = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: SvEspace.l),
                  Text('Avatar', style: texte.titleMedium),
                  const SizedBox(height: SvEspace.s),
                  Wrap(
                    spacing: SvEspace.s,
                    runSpacing: SvEspace.s,
                    children: [
                      for (final emoji in _emojisProposes)
                        _CaseAvatar(
                          // Pour la case « initiale », on montre la lettre du prénom tapé.
                          contenu: emoji ?? apercu.copyWith(retirerEmoji: true).avatar,
                          choisie: emoji == _emoji,
                          onTap: () => setState(() => _emoji = emoji),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SvEspace.m),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _enregistrer,
                  child: const Text('ENREGISTRER'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un rond de couleur à choisir, coché quand il est sélectionné.
class _PastilleCouleur extends StatelessWidget {
  const _PastilleCouleur({
    required this.couleur,
    required this.nom,
    required this.choisie,
    required this.onTap,
  });

  final Color couleur;
  final String nom;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Semantics : décrit le rond pour le lecteur d'écran (accessibilité).
    return Semantics(
      label: nom,
      selected: choisie,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: couleur,
            shape: BoxShape.circle,
            // Un anneau de la couleur du texte autour de la couleur choisie.
            border: choisie ? Border.all(color: context.sv.ink, width: 3) : null,
          ),
          child: choisie
              ? Icon(Icons.check, color: SvCouleursJoueurs.texteSur(context), size: 28)
              : null,
        ),
      ),
    );
  }
}

/// Une case d'avatar à choisir (emoji ou initiale).
class _CaseAvatar extends StatelessWidget {
  const _CaseAvatar({required this.contenu, required this.choisie, required this.onTap});

  final String contenu;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sv = context.sv;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SvArrondi.carte),
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: choisie ? sv.tealSoft : sv.surfaceRaised,
          borderRadius: BorderRadius.circular(SvArrondi.carte),
          border: Border.all(color: choisie ? sv.teal : sv.line, width: choisie ? 2 : 1),
        ),
        child: Text(
          contenu,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: sv.ink, height: 1),
        ),
      ),
    );
  }
}
