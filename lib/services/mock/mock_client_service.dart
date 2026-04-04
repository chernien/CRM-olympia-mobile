import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../models/client_model.dart';
import '../client_service.dart';
import 'mock_data.dart';

class MockClientService extends ClientService {
  MockClientService(DioClient dioClient) : super(dioClient);

  @override
  Future<Either<Failure, List<ClientModel>>> searchClients(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final q = query.toLowerCase();
    final results = MockData.clients
        .where((c) =>
            c.code.toLowerCase().contains(q) ||
            c.nom.toLowerCase().contains(q) ||
            (c.ville?.toLowerCase().contains(q) ?? false))
        .toList();

    return Right(results);
  }

  @override
  Future<Either<Failure, ClientModel>> getClientByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final client = MockData.clients.where((c) => c.code == code).firstOrNull;
    if (client == null) {
      return const Left(ServerFailure(message: 'Client introuvable', statusCode: 404));
    }
    return Right(client);
  }
}
