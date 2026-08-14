import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Affichage des pièces jointes d'une demande.
///
/// Les fichiers sont servis par un endpoint AUTHENTIFIÉ (`/api/fichiers/{id}`) : une photo
/// de chantier est une donnée client, elle n'est pas publique. Chaque image porte donc son
/// en-tête `Authorization` — [Image.network] l'accepte, contrairement à une balise `<img>`
/// côté web où il a fallu passer par un blob.
///
/// Le jeton est lu une seule fois et partagé par toutes les vignettes : le relire par image
/// multiplierait les accès au stockage sécurisé pour rien.
class PiecesJointes extends StatefulWidget {
  final List<String> urls;
  final String titre;

  const PiecesJointes({super.key, required this.urls, this.titre = 'Pièces jointes'});

  @override
  State<PiecesJointes> createState() => _PiecesJointesState();
}

class _PiecesJointesState extends State<PiecesJointes> {
  static const _storage = FlutterSecureStorage();
  Map<String, String>? _entetes;

  @override
  void initState() {
    super.initState();
    _chargerJeton();
  }

  Future<void> _chargerJeton() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (!mounted) return;
    setState(() => _entetes = token == null ? {} : {'Authorization': 'Bearer $token'});
  }

  /// Les URL stockées sont relatives (« /api/fichiers/… ») pour survivre à un changement
  /// de domaine. On les rattache ici à la base courante.
  String _absolue(String url) {
    if (url.startsWith('http')) return url;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$base$url';
  }

  bool _estImage(String url) =>
      RegExp(r'\.(jpg|jpeg|png|webp|gif)$', caseSensitive: false).hasMatch(url) ||
      url.contains('/api/fichiers/'); // le serveur renvoie le bon type ; on tente l'image

  @override
  Widget build(BuildContext context) {
    final liste = widget.urls.where((u) => u.trim().isNotEmpty).toList();
    if (liste.isEmpty) return const SizedBox.shrink();
    if (_entetes == null) {
      return SizedBox(height: 90.h, child: const Center(child: CircularProgressIndicator.adaptive()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.titre} (${liste.length})',
            style: TextStyle(
                fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: liste.map((u) => _vignette(_absolue(u))).toList(),
        ),
      ],
    );
  }

  Widget _vignette(String url) {
    if (!_estImage(url)) return _tuileDocument(url);
    return GestureDetector(
      onTap: () => _ouvrirEnGrand(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          url,
          headers: _entetes,
          width: 84.w, height: 84.w, fit: BoxFit.cover,
          loadingBuilder: (c, child, p) => p == null
              ? child
              : Container(
                  width: 84.w, height: 84.w, color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2))),
          // Une pièce jointe manquante ne doit pas casser la fiche : les demandes créées
          // avant le vrai stockage portent des URL mortes.
          errorBuilder: (c, e, s) => Container(
            width: 84.w, height: 84.w,
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border)),
            child: Icon(Icons.broken_image_outlined, size: 22.r, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _tuileDocument(String url) => Container(
        width: 84.w, height: 84.w,
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border)),
        child: Icon(Icons.insert_drive_file_outlined, size: 24.r, color: AppColors.textSecondary),
      );

  /// Plein écran avec zoom : sur un téléphone, une vignette de 84 dp ne permet pas de
  /// juger un défaut de peinture — ce pour quoi la photo a été prise.
  void _ouvrirEnGrand(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.r),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1, maxScale: 4,
              child: Center(child: Image.network(url, headers: _entetes)),
            ),
            Positioned(
              top: 0, right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Fermer',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
