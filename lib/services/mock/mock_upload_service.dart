import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../upload_service.dart';

class MockUploadService extends UploadService {
  MockUploadService(super.dioClient, super.networkInfo);

  @override
  Future<Either<Failure, String>> uploadFile(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final fakeName = filePath.split('/').last.split('\\').last;
    return Right('https://mock-storage.olympia.com/uploads/$fakeName');
  }
}
