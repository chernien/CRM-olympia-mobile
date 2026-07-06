import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/task_service.dart';
import '../../services/demande_service.dart';
import '../../services/client_service.dart';
import '../../services/upload_service.dart';
import '../../services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt()),
  );

  // ─── Services (all wired to the real .NET backend) ─────────────
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt(), getIt()),
  );
  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(getIt(), getIt()),
  );
  getIt.registerLazySingleton<TaskService>(
    () => TaskService(getIt(), getIt()),
  );
  getIt.registerLazySingleton<DemandeService>(
    () => DemandeService(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ClientService>(
    () => ClientService(getIt(), getIt()),
  );
  getIt.registerLazySingleton<UploadService>(
    () => UploadService(getIt(), getIt()),
  );
}
