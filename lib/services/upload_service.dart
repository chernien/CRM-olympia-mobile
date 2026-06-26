import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';

class UploadService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  UploadService(this._dioClient, this._networkInfo);

  Future<Either<Failure, String>> uploadFile(String filePath) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dioClient.uploadFile(
        ApiConstants.upload,
        formData: formData,
      );
      // Envelope: { "data": { "url": "..." } }
      final data = (response.data is Map && response.data['data'] is Map)
          ? response.data['data']
          : response.data;
      return Right(data['url'] as String);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }
}
