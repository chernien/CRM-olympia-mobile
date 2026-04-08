import 'package:flutter/material.dart';
import 'forms/demande_echantillons_form.dart';
import 'forms/demande_echantillons_application_form.dart';
import 'forms/demande_reclamation_form.dart';
import 'forms/demande_nouveau_client_form.dart';
import 'forms/demande_showroom_form.dart';
import 'forms/demande_formation_form.dart';
import 'forms/demande_assistance_form.dart';
import 'forms/demande_simple_form.dart';

class DemandeFormView extends StatelessWidget {
  final int type;
  const DemandeFormView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      1 => const DemandeEchantillonsForm(),
      2 => const DemandeEchantillonsApplicationForm(),
      3 => const DemandeReclamationForm(),
      4 => const DemandeNouveauClientForm(),
      5 => const DemandeShowroomForm(),
      6 => const DemandeFormationForm(),
      7 => const DemandeAssistanceForm(),
      8 => const DemandeSimpleForm(type: 8, title: 'Machine à teinter'),
      9 => const DemandeSimpleForm(type: 9, title: 'Accessoires marketing'),
      _ => DemandeSimpleForm(type: type, title: 'Nouvelle demande'),
    };
  }
}
