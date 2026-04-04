import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/client_model.dart';

class ClientService {
  final DioClient _dioClient;

  ClientService(this._dioClient);

  Future<Either<Failure, List<ClientModel>>> searchClients(String query) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.clientSearch,
        queryParameters: {'q': query},
      );
      final clients = (response.data as List)
          .map((e) => ClientModel.fromJson(e))
          .toList();
      return Right(clients);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  Future<Either<Failure, ClientModel>> getClientByCode(String code) async {
    try {
      final response = await _dioClient.get('${ApiConstants.clients}/$code');
      return Right(ClientModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
