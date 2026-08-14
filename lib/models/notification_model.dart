import 'package:equatable/equatable.dart';

import '../core/utils/server_date.dart';

/// Une notification telle que servie par `GET /api/notifications`.
///
/// Le message FCM ne transporte que des identifiants ; c'est ce modèle, chargé
/// depuis l'API REST, qui porte le contenu réellement affiché.
class NotificationModel extends Equatable {
  final String id;
  final String type; // demande_a_traiter | demande_cloturee | tache_creee | objectif_cree
  final String titre;
  final String message;
  final String? demandeId;
  final String? tacheId;
  final String? objectifId;
  final String priorite; // haute | normale
  final bool lu;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.demandeId,
    this.tacheId,
    this.objectifId,
    this.priorite = 'normale',
    this.lu = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id']?.toString() ?? '',
        type: json['type'] as String? ?? '',
        titre: json['titre'] as String? ?? '',
        message: json['message'] as String? ?? '',
        demandeId: json['demandeId']?.toString(),
        tacheId: json['tacheId']?.toString(),
        objectifId: json['objectifId']?.toString(),
        priorite: json['priorite'] as String? ?? 'normale',
        lu: json['lu'] as bool? ?? false,
        // UTC sans `Z` côté backend : ServerDate rétablit le fuseau (voir la classe).
        createdAt: ServerDate.tryParse(json['createdAt']),
      );

  NotificationModel copyWith({bool? lu}) => NotificationModel(
        id: id,
        type: type,
        titre: titre,
        message: message,
        demandeId: demandeId,
        tacheId: tacheId,
        objectifId: objectifId,
        priorite: priorite,
        lu: lu ?? this.lu,
        createdAt: createdAt,
      );

  /// Libellé de catégorie affiché sur la carte.
  String get categorie => switch (type) {
        'demande_a_traiter' || 'demande_cloturee' => 'Demande',
        'tache_creee' => 'Tâche',
        'objectif_cree' => 'Objectif',
        _ => 'Notification',
      };

  @override
  List<Object?> get props =>
      [id, type, titre, message, demandeId, tacheId, objectifId, priorite, lu, createdAt];
}

/// Réponse paginée + compteur de non-lues (la pastille).
class NotificationPage extends Equatable {
  final List<NotificationModel> items;
  final int total;
  final int nonLues;

  const NotificationPage({
    this.items = const [],
    this.total = 0,
    this.nonLues = 0,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        items: ((json['data'] as List?) ?? const [])
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
        nonLues: json['nonLues'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [items, total, nonLues];
}
