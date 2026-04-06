import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../models/demande_model.dart';
import '../demande_service.dart';
import 'mock_data.dart';

class MockDemandeService extends DemandeService {
  final List<DemandeModel> _demandes = List.from(MockData.demandes);
  int _counter = MockData.demandes.length;

  MockDemandeService(super.dioClient);

  @override
  Future<Either<Failure, List<DemandeModel>>> getDemandes({
    int page = 1,
    int pageSize = 20,
    int? typeDemande,
    String? statut,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var filtered = _demandes.toList();
    if (typeDemande != null) {
      filtered = filtered.where((d) => d.typeDemande == typeDemande).toList();
    }
    if (statut != null) {
      filtered = filtered.where((d) => d.statut == statut).toList();
    }

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return const Right([]);

    final end = start + pageSize;
    return Right(filtered.sublist(start, end.clamp(0, filtered.length)));
  }

  @override
  Future<Either<Failure, DemandeModel>> getDemandeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final demande = _demandes.where((d) => d.id == id).firstOrNull;
    if (demande == null) {
      return const Left(ServerFailure(message: 'Demande introuvable', statusCode: 404));
    }
    return Right(demande);
  }

  @override
  Future<Either<Failure, DemandeModel>> createDemande(DemandeModel demande) async {
    await Future.delayed(const Duration(milliseconds: 800));

    _counter++;
    final newDemande = DemandeModel(
      id: 'dem-${_counter.toString().padLeft(3, '0')}',
      numero: 'D-2026-${_counter.toString().padLeft(4, '0')}',
      typeDemande: demande.typeDemande,
      statut: 'nouvelle',
      commercialId: 'usr-001',
      commercialNom: 'Taha Mejdoub',
      formData: demande.formData,
      commentaire: demande.commentaire,
      createdAt: DateTime.now(),
      historique: [
        DemandeHistorique(
          action: 'Création',
          auteur: 'Taha Mejdoub',
          date: DateTime.now(),
        ),
      ],
    );
    _demandes.insert(0, newDemande);
    return Right(newDemande);
  }

  @override
  Future<Either<Failure, DemandeModel>> updateDemandeStatus(
    String demandeId,
    String statut, {
    String? commentaire,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _demandes.indexWhere((d) => d.id == demandeId);
    if (index == -1) {
      return const Left(ServerFailure(message: 'Demande introuvable', statusCode: 404));
    }

    final old = _demandes[index];
    final updated = DemandeModel(
      id: old.id,
      numero: old.numero,
      typeDemande: old.typeDemande,
      statut: statut,
      commercialId: old.commercialId,
      commercialNom: old.commercialNom,
      formData: old.formData,
      piecesJointes: old.piecesJointes,
      historique: [
        ...?old.historique,
        DemandeHistorique(
          action: 'Statut changé en $statut',
          auteur: 'Système',
          date: DateTime.now(),
          commentaire: commentaire,
        ),
      ],
      commentaire: commentaire ?? old.commentaire,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    _demandes[index] = updated;
    return Right(updated);
  }
}
