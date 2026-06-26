import 'package:dartz/dartz.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/errors/exceptions.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../models/client_model.dart';

class ClientService {
  final DioClient _dioClient;
  final NetworkInfo _networkInfo;

  ClientService(this._dioClient, this._networkInfo);

  Future<Either<Failure, List<ClientModel>>> searchClients(String query) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get(
        ApiConstants.clientSearch,
        queryParameters: {'q': query},
      );
      // Envelope: { "data": [ ClientDto, ... ] }
      final list = (response.data['data'] ?? response.data) as List;
      final clients = list
          .map((e) => ClientModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(clients);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }

  Future<Either<Failure, ClientModel>> getClientByCode(String code) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dioClient.get('${ApiConstants.clients}/$code');
      // Envelope: { "data": { ClientDto } }
      final data = (response.data is Map && response.data['data'] is Map)
          ? response.data['data']
          : response.data;
      return Right(ClientModel.fromJson(data as Map<String, dynamic>));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur de données: $e'));
    }
  }
}
