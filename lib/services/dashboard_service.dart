import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final DioClient _dioClient;

  DashboardService(this._dioClient);

  Future<Either<Failure, CAData>> getCaMensuel({int? mois, int? annee}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.caMensuel,
        queryParameters: {
          'mois': ?mois,
          'annee': ?annee,
        },
      );
      return Right(CAData.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, CAData>> getCaTrimestriel({int? trimestre, int? annee}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.caTrimestriel,
        queryParameters: {
          'trimestre': ?trimestre,
          'annee': ?annee,
        },
      );
      return Right(CAData.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, StatsVisites>> getStatsVisites() async {
    try {
      final response = await _dioClient.get(ApiConstants.statsVisites);
      return Right(StatsVisites.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, StatsTaches>> getStatsTaches() async {
    try {
      final response = await _dioClient.get(ApiConstants.statsTaches);
      return Right(StatsTaches.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
