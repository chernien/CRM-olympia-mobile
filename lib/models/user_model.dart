import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role; // 'commercial' | 'admin'
  final String? zone;
  final double? objectifCA;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.zone,
    this.objectifCA,
    this.isActive = true,
  });

  String get fullName => '$prenom $nom';
  bool get isCommercial => role == 'commercial';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, email, nom, prenom, role];
}
