// joueur.dart — un joueur de la famille : prénom, couleur, avatar.
//
// C'est une classe de données « pure » : aucun widget, aucune sauvegarde.
// Elle sait seulement se transformer en JSON (pour être enregistrée)
// et se recréer à partir de ce JSON.

/// Un joueur enregistré.
///
/// Les champs sont `final` : un joueur ne change jamais « sur place ».
/// Pour le modifier, on crée une copie modifiée avec [copyWith].
/// C'est plus sûr : personne ne peut changer un joueur dans le dos d'un écran.
class Joueur {
  const Joueur({
    required this.id,
    required this.prenom,
    required this.couleur,
    this.emoji,
  });

  /// Identifiant unique, qui ne change jamais (même si on renomme le joueur).
  final String id;

  /// Prénom affiché en gros (ex. « Gaby »).
  final String prenom;

  /// Numéro de la couleur du joueur dans `SvCouleursJoueurs` (0 à 7).
  final int couleur;

  /// Emoji choisi comme avatar, ou `null` pour afficher l'initiale du prénom.
  final String? emoji;

  /// Ce qu'on affiche dans le rond de l'avatar : l'emoji, sinon l'initiale.
  String get avatar => emoji ?? (prenom.isEmpty ? '?' : prenom.premiereLettre.toUpperCase());

  /// Copie du joueur avec certains champs changés.
  ///
  /// Pour l'emoji, on ne peut pas utiliser `emoji ?? this.emoji` : on ne
  /// pourrait jamais *revenir* à l'initiale (null voudrait dire « inchangé »).
  /// D'où le paramètre séparé [retirerEmoji].
  Joueur copyWith({String? prenom, int? couleur, String? emoji, bool retirerEmoji = false}) {
    return Joueur(
      id: id,
      prenom: prenom ?? this.prenom,
      couleur: couleur ?? this.couleur,
      emoji: retirerEmoji ? null : (emoji ?? this.emoji),
    );
  }

  /// Transforme le joueur en `Map` (dictionnaire clé → valeur), facile à
  /// convertir en texte JSON pour la sauvegarde.
  Map<String, dynamic> toJson() => {
        'id': id,
        'prenom': prenom,
        'couleur': couleur,
        'emoji': emoji,
      };

  /// Recrée un joueur à partir de sa `Map` JSON.
  ///
  /// Un `factory` est un constructeur qui peut faire des calculs avant de
  /// créer l'objet. Ici on se protège des données abîmées : valeurs par défaut
  /// si un champ manque.
  factory Joueur.fromJson(Map<String, dynamic> json) {
    return Joueur(
      id: json['id'] as String,
      prenom: (json['prenom'] as String?) ?? '',
      couleur: (json['couleur'] as int?) ?? 0,
      emoji: json['emoji'] as String?,
    );
  }
}

/// Petite aide pour prendre la première « lettre » d'un texte.
///
/// Pourquoi pas `prenom[0]` ? Parce qu'un caractère accentué ou un emoji
/// peut occuper plusieurs cases en mémoire : `[0]` n'en prendrait qu'un morceau.
/// `runes` découpe le texte en vrais caractères.
extension _PremiereLettre on String {
  String get premiereLettre => String.fromCharCode(runes.first);
}
