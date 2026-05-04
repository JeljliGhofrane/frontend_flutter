// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String role;
  final String nom;
  final String prenom;
  final bool   isApproved;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.nom,
    required this.prenom,
    this.isApproved = true,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id         : json['id']         as String? ?? json['_id'] as String? ?? '',
    email      : json['email']      as String? ?? '',
    role       : json['role']       as String? ?? 'technicien',
    nom        : json['nom']        as String? ?? '',
    prenom     : json['prenom']     as String? ?? '',
    isApproved : json['isApproved'] as bool?   ?? true,
    avatar     : json['avatar']     as String?,
  );

  Map<String, dynamic> toJson() => {
    'id'        : id,
    'email'     : email,
    'role'      : role,
    'nom'       : nom,
    'prenom'    : prenom,
    'isApproved': isApproved,
    'avatar'    : avatar,
  };

  String get fullName => '$prenom $nom'.trim();

  String get roleLabel {
    switch (role) {
      case 'admin':       return 'Administrateur';
      case 'technicien':  return 'Technicien Réseau';
      case 'employe':     return 'Employé Autorisé';
      default:            return role;
    }
  }

  bool get isAdmin      => role == 'admin';
  bool get isTechnicien => role == 'technicien';
  bool get isEmploye    => role == 'employe';
  bool get canViewData  => role == 'admin' || role == 'technicien';
}