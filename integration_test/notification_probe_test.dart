import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:olympia_app/core/config/injection.dart';
import 'package:olympia_app/services/notification_service.dart';
import 'package:olympia_app/services/push_service.dart';

/// Sonde d'affichage des notifications, à exécuter sur un téléphone réel :
///
/// ```
/// flutter test integration_test/notification_probe_test.dart -d bf742788
/// ```
///
/// **Pourquoi ce test existe.** Le rôle IAM `firebase.sdkAdminServiceAgent`
/// n'est pas encore accordé au compte de service : le backend ne peut pas
/// pousser de message FCM, donc le maillon « push réel → bannière » n'est pas
/// testable aujourd'hui. Ce test attaque le maillon suivant, celui qui était
/// cassé : il appelle `PushService.showLocally` — exactement ce que
/// `_handleMessage` fait à la réception d'un message — avec une charge utile
/// data-only identique à celle produite par le backend.
///
/// Le délai final laisse le temps de capturer l'écran :
/// `adb -s <device> exec-out screencap -p > banniere.png`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'une charge utile FCM simulée produit une bannière sur le canal haute importance',
    (tester) async {
      await tester.runAsync(() async {
        await configureDependencies();

        final local = getIt<NotificationService>();
        await local.init();
        await local.requestPermission();

        final push = getIt<PushService>();

        // Charge utile strictement identique à celle du backend (data-only,
        // trois clés, aucune donnée métier).
        await push.showLocally({
          'type': 'demande_a_traiter',
          'id': '9f2c1b30-0000-4000-8000-000000000001',
          'notificationId': '9f2c1b30-0000-4000-8000-0000000000ff',
        });

        // Fenêtre de capture d'écran (la bannière heads-up reste visible
        // quelques secondes ; le tiroir, lui, la conserve).
        await Future<void>.delayed(const Duration(seconds: 10));
      });
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
