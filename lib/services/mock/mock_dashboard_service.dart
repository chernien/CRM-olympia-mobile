import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../models/dashboard_model.dart';
import '../dashboard_service.dart';
import 'mock_data.dart';

class MockDashboardService extends DashboardService {
  MockDashboardService(DioClient dioClient) : super(dioClient);

  @override
  Future<Either<Failure, CAData>> getCaMensuel({int? mois, int? annee}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(MockData.caMensuel);
  }

  @override
  Future<Either<Failure, CAData>> getCaTrimestriel({int? trimestre, int? annee}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(MockData.caTrimestriel);
  }

  @override
  Future<Either<Failure, StatsVisites>> getStatsVisites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(MockData.statsVisites);
  }

  @override
  Future<Either<Failure, StatsTaches>> getStatsTaches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(MockData.statsTaches);
  }
}
