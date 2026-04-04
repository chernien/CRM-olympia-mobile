import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'app_config.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/task_service.dart';
import '../../services/demande_service.dart';
import '../../services/client_service.dart';
import '../../services/upload_service.dart';
import '../../services/mock/mock_auth_service.dart';
import '../../services/mock/mock_dashboard_service.dart';
import '../../services/mock/mock_task_service.dart';
import '../../services/mock/mock_demande_service.dart';
import '../../services/mock/mock_client_service.dart';
import '../../services/mock/mock_upload_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  if (AppConfig.useMockData) {
    // ─── MOCK MODE ─────────────────────────────────────────────
    // DioClient is created but never used (satisfies parent constructors).
    // Login: taha@olympia.com / password123  (commercial)
    //        admin@olympia.com / admin123     (admin)
    getIt.registerLazySingleton<DioClient>(
      () => DioClient(getIt()),
    );
    getIt.registerLazySingleton<AuthService>(
      () => MockAuthService(getIt(), getIt()),
    );
    getIt.registerLazySingleton<DashboardService>(
      () => MockDashboardService(getIt()),
    );
    getIt.registerLazySingleton<TaskService>(
      () => MockTaskService(getIt()),
    );
    getIt.registerLazySingleton<DemandeService>(
      () => MockDemandeService(getIt()),
    );
    getIt.registerLazySingleton<ClientService>(
      () => MockClientService(getIt()),
    );
    getIt.registerLazySingleton<UploadService>(
      () => MockUploadService(getIt()),
    );
  } else {
    // ─── REAL API MODE ─────────────────────────────────────────
    getIt.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.instance,
    );
    getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt()),
    );
    getIt.registerLazySingleton<DioClient>(
      () => DioClient(getIt()),
    );
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(getIt(), getIt()),
    );
    getIt.registerLazySingleton<DashboardService>(
      () => DashboardService(getIt()),
    );
    getIt.registerLazySingleton<TaskService>(
      () => TaskService(getIt()),
    );
    getIt.registerLazySingleton<DemandeService>(
      () => DemandeService(getIt()),
    );
    getIt.registerLazySingleton<ClientService>(
      () => ClientService(getIt()),
    );
    getIt.registerLazySingleton<UploadService>(
      () => UploadService(getIt()),
    );
  }
}
