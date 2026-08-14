import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

/// Bandeau permanent affiché dès que le téléphone perd le réseau.
///
/// Il répond à un défaut de terrain : jusqu'ici, un commercial hors couverture
/// remplissait tout son formulaire, appuyait sur « Soumettre », et attendait
/// TRENTE SECONDES — le délai d'expiration — avant de comprendre. Il le sait
/// désormais avant d'agir.
///
/// Il n'EMPÊCHE rien : il informe. Aucune requête n'est bloquée, aucun bouton
/// désactivé. C'est délibéré — l'application se connecte parfois au backend par
/// un tunnel USB (`adb reverse`) alors que le téléphone n'a ni Wi-Fi ni données ;
/// bloquer sur l'état système rendrait le débogage impossible et, en clientèle,
/// couperait l'application sur un faux négatif. Voir aussi la note de
/// [NetworkInfoImpl], qui laisse passer les requêtes pour la même raison.
class BandeauHorsLigne extends StatefulWidget {
  final Widget child;

  const BandeauHorsLigne({super.key, required this.child});

  @override
  State<BandeauHorsLigne> createState() => _BandeauHorsLigneState();
}

class _BandeauHorsLigneState extends State<BandeauHorsLigne> {
  StreamSubscription<List<ConnectivityResult>>? _abonnement;
  bool _horsLigne = false;

  @override
  void initState() {
    super.initState();
    _ecouter();
  }

  Future<void> _ecouter() async {
    final connectivite = Connectivity();
    // État initial : sans cette lecture, un lancement déjà hors réseau
    // n'afficherait rien tant que l'état ne CHANGE pas.
    try {
      _appliquer(await connectivite.checkConnectivity());
    } catch (_) {
      // Plateforme sans le plugin : on reste silencieux plutôt que d'afficher
      // un bandeau permanent à tort.
    }
    _abonnement = connectivite.onConnectivityChanged.listen(_appliquer);
  }

  void _appliquer(List<ConnectivityResult> etats) {
    // La liste peut contenir plusieurs interfaces ; hors ligne = TOUTES à none.
    final horsLigne = etats.isNotEmpty && etats.every((e) => e == ConnectivityResult.none);
    if (horsLigne != _horsLigne && mounted) {
      setState(() => _horsLigne = horsLigne);
    }
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AnimatedSize plutôt qu'un simple if : le contenu se décale en douceur
        // au lieu de sauter, ce qui évite de faire rater un appui en cours.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _horsLigne ? _bandeau(context) : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _bandeau(BuildContext context) => Material(
        color: AppColors.error,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.wifi_off_rounded, size: 16.r, color: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Hors connexion — vos saisies ne seront pas envoyées',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
