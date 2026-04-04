import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';

class UploadService {
  final DioClient _dioClient;

  UploadService(this._dioClient);

  Future<Either<Failure, String>> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dioClient.uploadFile(
        ApiConstants.upload,
        formData: formData,
      );
      return Right(response.data['url'] as String);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
