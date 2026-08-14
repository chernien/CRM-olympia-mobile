import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_app/core/utils/server_date.dart';
import 'package:olympia_app/models/notification_model.dart';
import 'package:olympia_app/models/task_model.dart';

/// Verrou de non-régression sur le décalage d'une heure.
///
/// Le backend .NET sérialise ses `DateTime` en UTC **sans suffixe `Z`**
/// (vérifié sur `GET /api/demandes` : `"createdAt":"2026-08-04T10:26:12.5567932"`
/// alors qu'il était 11h26 en Tunisie). Sans [ServerDate], `DateTime.parse` lit
/// ces chaînes comme des heures locales et toute l'application affiche « il y a
/// 1 h » pour un événement qui vient de se produire.
void main() {
  group('ServerDate', () {
    test('traite un horodatage sans fuseau comme de l\'UTC', () {
      final parsed = ServerDate.tryParse('2026-08-04T09:58:38')!;
      expect(parsed.isUtc, isFalse, reason: 'la valeur rendue est locale');
      expect(parsed.toUtc(), DateTime.utc(2026, 8, 4, 9, 58, 38));
    });

    test('conserve les fractions de seconde', () {
      expect(
        ServerDate.tryParse('2026-08-04T10:26:12.5567932')!.toUtc(),
        DateTime.utc(2026, 8, 4, 10, 26, 12, 556, 793),
      );
    });

    test('respecte un `Z` déjà présent', () {
      expect(
        ServerDate.tryParse('2026-08-04T09:58:38Z')!.toUtc(),
        DateTime.utc(2026, 8, 4, 9, 58, 38),
      );
    });

    test('respecte un décalage explicite', () {
      expect(
        ServerDate.tryParse('2026-08-04T11:58:38+02:00')!.toUtc(),
        DateTime.utc(2026, 8, 4, 9, 58, 38),
      );
    });

    test('ne déplace pas une date seule', () {
      final parsed = ServerDate.tryParse('2026-08-04')!;
      expect(parsed.year, 2026);
      expect(parsed.month, 8);
      expect(parsed.day, 4);
    });

    test('tolère null, vide et illisible', () {
      expect(ServerDate.tryParse(null), isNull);
      expect(ServerDate.tryParse('   '), isNull);
      expect(ServerDate.tryParse('pas une date'), isNull);
    });

    test('sérialise toujours en UTC explicite', () {
      expect(
        ServerDate.toJson(DateTime.utc(2026, 8, 4, 9, 58, 38)),
        '2026-08-04T09:58:38.000Z',
      );
    });
  });

  group('modèles branchés sur ServerDate', () {
    test('NotificationModel.createdAt', () {
      final n = NotificationModel.fromJson(const {
        'id': '1',
        'type': 'objectif_cree',
        'titre': 'Nouvel objectif',
        'message': 'Un nouvel objectif vous est assigné.',
        'createdAt': '2026-08-04T09:58:38',
      });
      expect(n.createdAt!.toUtc(), DateTime.utc(2026, 8, 4, 9, 58, 38));
    });

    test('TaskModel.createdAt', () {
      final t = TaskModel.fromJson(const {
        'codeClient': 'C1',
        'nomClient': 'Client',
        'createdAt': '2026-08-04T09:58:38',
      });
      expect(t.createdAt!.toUtc(), DateTime.utc(2026, 8, 4, 9, 58, 38));
    });
  });
}
