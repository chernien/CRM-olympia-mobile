import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/service_providers.dart';
import '../core/errors/failures.dart';
import '../models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> items;
  final int nonLues;
  final bool isLoading;
  final Failure? error;

  const NotificationState({
    this.items = const [],
    this.nonLues = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? items,
    int? nonLues,
    bool? isLoading,
    Failure? error,
  }) =>
      NotificationState(
        items: items ?? this.items,
        nonLues: nonLues ?? this.nonLues,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// État de l'écran Notifications.
///
/// La source de vérité est l'API REST : FCM ne fait que déclencher un [load].
class NotificationNotifier extends Notifier<NotificationState> {
  StreamSubscription<Map<String, String>>? _openSub;
  StreamSubscription<Map<String, String>>? _receivedSub;

  @override
  NotificationState build() {
    // Un push reçu (ou ouvert) signifie qu'il y a du neuf côté serveur : on
    // recharge la liste plutôt que de reconstruire le contenu depuis la charge utile.
    // `onReceived` est ce qui fait bouger la pastille du tableau de bord sans
    // que l'utilisateur ait besoin d'ouvrir la notification.
    final push = ref.read(pushServiceProvider);
    _openSub = push.onOpen.listen((_) => load());
    _receivedSub = push.onReceived.listen((_) => load());
    ref.onDispose(() {
      _openSub?.cancel();
      _receivedSub?.cancel();
    });
    return const NotificationState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final result =
        await ref.read(notificationApiServiceProvider).getNotifications();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (page) => state = state.copyWith(
        isLoading: false,
        items: page.items,
        nonLues: page.nonLues,
      ),
    );
  }

  Future<void> markRead(String id) async {
    final index = state.items.indexWhere((n) => n.id == id);
    if (index == -1 || state.items[index].lu) return;

    // Optimiste : la pastille doit répondre au geste, pas à l'aller-retour réseau.
    final items = [...state.items];
    items[index] = items[index].copyWith(lu: true);
    state = state.copyWith(
      items: items,
      nonLues: state.nonLues > 0 ? state.nonLues - 1 : 0,
    );

    final result = await ref.read(notificationApiServiceProvider).markRead(id);
    result.fold(
      (_) => load(), // resynchronise si le serveur a refusé
      (nonLues) => state = state.copyWith(nonLues: nonLues),
    );
  }

  Future<void> markAllRead() async {
    if (state.nonLues == 0) return;
    final items = state.items.map((n) => n.copyWith(lu: true)).toList();
    state = state.copyWith(items: items, nonLues: 0);

    final result = await ref.read(notificationApiServiceProvider).markAllRead();
    result.fold((_) => load(), (_) {});
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        NotificationNotifier.new);
