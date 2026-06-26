import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'injection.dart';
import '../network/dio_client.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/task_service.dart';
import '../../services/demande_service.dart';
import '../../services/client_service.dart';
import '../../services/upload_service.dart';

/// Riverpod provider wrappers around GetIt singletons.
///
/// Why: ViewModels that call `getIt<Service>()` directly are coupled to the
/// GetIt container and cannot be overridden in unit tests. Exposing services
/// as Providers lets tests do:
///   ProviderContainer(overrides: [taskServiceProvider.overrideWithValue(mock)])
/// without booting the entire DI container.

final authServiceProvider =
    Provider<AuthService>((ref) => getIt<AuthService>());

final dashboardServiceProvider =
    Provider<DashboardService>((ref) => getIt<DashboardService>());

final taskServiceProvider =
    Provider<TaskService>((ref) => getIt<TaskService>());

final demandeServiceProvider =
    Provider<DemandeService>((ref) => getIt<DemandeService>());

final clientServiceProvider =
    Provider<ClientService>((ref) => getIt<ClientService>());

final uploadServiceProvider =
    Provider<UploadService>((ref) => getIt<UploadService>());

final dioClientProvider =
    Provider<DioClient>((ref) => getIt<DioClient>());
