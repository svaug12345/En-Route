// joueurs.dart — l'écran « Joueurs » : la liste des joueurs enregistrés.
// Toucher un joueur pour le modifier, bouton en bas pour en ajouter un.
//
// Les joueurs sont créés une fois et réutilisés dans tous les jeux.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/joueurs_service.dart';
import '../theme/sv_theme.dart';
import '../widgets/avatar_joueur.dart';
import 'edition_joueur.dart';

/// Écran de gestion des joueurs.
class EcranJoueurs extends StatelessWidget {
  const EcranJoueurs({super.key});

  /// Ouvre l'écran d'édition. Sans joueur → création ; avec → modification.
  void _ouvrirEdition(BuildContext context, {String? idJoueur}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditionJoueur(idJoueur: idJoueur)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.watch : « donne-moi le service ET redessine cet écran quand il
    // change ». Après un ajout ou une suppression, la liste se met à jour seule.
    final service = context.watch<JoueursService>();
    final joueurs = service.joueurs;
    final sv = context.sv;
    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Joueurs')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: joueurs.isEmpty
                  // Liste vide : on explique quoi faire plutôt qu'un écran blanc.
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SvEspace.xl),
                        child: Text(
                          'Pas encore de joueur.\nAjoute toute la famille.',
                          textAlign: TextAlign.center,
                          style: texte.titleLarge?.copyWith(color: sv.inkMuted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(SvEspace.m),
                      itemCount: joueurs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: SvEspace.s),
                      itemBuilder: (context, index) {
                        final joueur = joueurs[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            minTileHeight: 72,
                            contentPadding: const EdgeInsets.symmetric(horizontal: SvEspace.m),
                            leading: AvatarJoueur(joueur: joueur),
                            title: Text(joueur.prenom, style: texte.titleLarge),
                            trailing: Icon(Icons.edit_outlined, color: sv.inkMuted),
                            onTap: () => _ouvrirEdition(context, idJoueur: joueur.id),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(SvEspace.m),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _ouvrirEdition(context),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('AJOUTER UN JOUEUR'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
