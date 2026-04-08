import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeAssistanceForm extends ConsumerStatefulWidget {
  const DemandeAssistanceForm({super.key});
  @override
  ConsumerState<DemandeAssistanceForm> createState() => _DemandeAssistanceFormState();
}

class _DemandeAssistanceFormState extends ConsumerState<DemandeAssistanceForm> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  final _clientController = TextEditingController();
  final _chantierController = TextEditingController();
  final _adresseController = TextEditingController();
  final _contactController = TextEditingController();
  final _telephoneContactController = TextEditingController();
  String _telephoneCountryCode = '+212';
  String _typeChantier = 'neuf';
  final _produitController = TextEditingController();
  final _surfaceController = TextEditingController();
  String _stadeChantier = 'preparation';
  String _objetAssistance = 'echantillon';
  String _niveauUrgence = 'normal';
  final _dateSouhaiteeController = TextEditingController();
  String _presenceConcurrente = 'non';
  final _detailsController = TextEditingController();

  final _technicienController = TextEditingController();
  final _dateInterventionController = TextEditingController();

  String _resultat = 'valide';
  final _commentaireController = TextEditingController();
  final _numeroBonController = TextEditingController();
  final _motifRejetController = TextEditingController();

  static const _stepTitles = ['Demande', 'Affectation', 'Résultat'];
  static const _stepIcons = [Icons.construction_outlined, Icons.engineering_outlined, Icons.check_circle_outline];
  static const _color = AppColors.secondary;

  @override
  void dispose() {
    _pageController.dispose(); _clientController.dispose(); _chantierController.dispose();
    _adresseController.dispose(); _contactController.dispose(); _telephoneContactController.dispose();
    _produitController.dispose(); _surfaceController.dispose(); _dateSouhaiteeController.dispose();
    _detailsController.dispose(); _technicienController.dispose(); _dateInterventionController.dispose();
    _commentaireController.dispose(); _numeroBonController.dispose(); _motifRejetController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < _totalSteps - 1) { setState(() => _currentStep++); _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }
      else { _submit(); }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) { setState(() => _currentStep--); _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }
    else { context.pop(); }
  }

  Future<void> _submit() async {
    final formData = <String, dynamic>{'client': _clientController.text, 'chantier': _chantierController.text, 'adresseChantier': _adresseController.text, 'contactSurPlace': _contactController.text, 'telephoneContact': _telephoneContactController.text, 'typeChantier': _typeChantier, 'produit': _produitController.text, 'surfaceEstimee': _surfaceController.text, 'stadeChantier': _stadeChantier, 'objetAssistance': _objetAssistance, 'niveauUrgence': _niveauUrgence, 'dateSouhaitee': _dateSouhaiteeController.text, 'presenceConcurrente': _presenceConcurrente, 'details': _detailsController.text, 'technicienAffecte': _technicienController.text, 'dateInterventionPrevue': _dateInterventionController.text, 'resultat': _resultat, 'commentaireFinal': _commentaireController.text, if (_resultat == 'valide') 'numeroBonCommande': _numeroBonController.text, if (_resultat == 'non_valide') 'motifRejet': _motifRejetController.text};
    final demande = DemandeModel(typeDemande: 7, formData: formData);
    final success = await ref.read(demandeListProvider.notifier).createDemande(demande);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Text(success ? 'Demande créée avec succès' : ref.read(demandeListProvider).error?.message ?? 'Une erreur est survenue')]), backgroundColor: success ? AppColors.primary : AppColors.secondary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    if (success) context.go(RouteNames.demandes);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(demandeListProvider.select((s) => s.isLoading));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, title: Text('Assistance chantier', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), foregroundColor: AppColors.textPrimary),
      body: Column(
        children: [
          FormStepIndicator(current: _currentStep, total: _totalSteps, titles: _stepTitles, icons: _stepIcons, color: _color, onTap: (i) { setState(() => _currentStep = i); _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }),
          Expanded(child: PageView(controller: _pageController, physics: const NeverScrollableScrollPhysics(), children: [_page(_formKeys[0], _phase1()), _page(_formKeys[1], _phase2()), _page(_formKeys[2], _phase3())])),
          FormBottomNav(isLoading: isLoading, isLast: _currentStep == _totalSteps - 1, isFirst: _currentStep == 0, onBack: _prevStep, onNext: _nextStep, color: _color),
        ],
      ),
    );
  }

  Widget _page(GlobalKey<FormState> key, Widget content) =>
      SingleChildScrollView(padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h), child: Form(key: key, child: content));

  Widget _phase1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const AppFormSection(title: 'Chantier & contact', icon: Icons.construction_outlined, color: _color), SizedBox(height: 14.h),
    AppTextField(controller: _clientController, hint: 'Client concerné', prefixIcon: Icons.business_outlined, required: true, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _chantierController, hint: 'Chantier concerné', prefixIcon: Icons.construction_outlined, required: true, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _adresseController, hint: 'Adresse du chantier', prefixIcon: Icons.location_on_outlined, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _contactController, hint: 'Contact sur place', prefixIcon: Icons.person_outline, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(
      controller: _telephoneContactController,
      hint: 'Téléphone du contact',
      accentColor: _color,
      phoneWithCountry: true,
      countryCode: _telephoneCountryCode,
      onCountryCodeChanged: (v) => setState(() => _telephoneCountryCode = v ?? _telephoneCountryCode),
      requiredMessage: 'Téléphone requis',
    ),
    SizedBox(height: 24.h),
    const AppFormSection(title: 'Détails techniques', icon: Icons.layers_outlined, color: _color), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _typeChantier, hint: 'Type de chantier', prefixIcon: Icons.home_work_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'neuf', child: Text('Neuf')), DropdownMenuItem(value: 'renovation', child: Text('Rénovation')), DropdownMenuItem(value: 'entretien', child: Text('Entretien')), DropdownMenuItem(value: 'autre', child: Text('Autre'))], onChanged: (v) => setState(() => _typeChantier = v!)), SizedBox(height: 14.h),
    AppTextField(controller: _produitController, hint: 'Produit concerné', prefixIcon: Icons.layers_outlined, required: true, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _surfaceController, hint: 'Surface estimée (m²)', prefixIcon: Icons.square_foot_outlined, accentColor: _color, keyboardType: TextInputType.number), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _stadeChantier, hint: 'Stade du chantier', prefixIcon: Icons.timeline_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'preparation', child: Text('Préparation')), DropdownMenuItem(value: 'en_cours', child: Text('En cours')), DropdownMenuItem(value: 'finition', child: Text('Finition')), DropdownMenuItem(value: 'reception', child: Text('Réception'))], onChanged: (v) => setState(() => _stadeChantier = v!)), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _objetAssistance, hint: "Objet de l'assistance", prefixIcon: Icons.help_outline, accentColor: _color, items: const [DropdownMenuItem(value: 'echantillon', child: Text('Échantillon')), DropdownMenuItem(value: 'probleme_technique', child: Text('Problème technique')), DropdownMenuItem(value: 'accompagnement_application', child: Text('Accompagnement application'))], onChanged: (v) => setState(() => _objetAssistance = v!)), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _niveauUrgence, hint: "Niveau d'urgence", prefixIcon: Icons.priority_high_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'normal', child: Text('Normal')), DropdownMenuItem(value: 'urgent', child: Text('Urgent')), DropdownMenuItem(value: 'tres_urgent', child: Text('Très urgent'))], onChanged: (v) => setState(() => _niveauUrgence = v!)), SizedBox(height: 14.h),
    AppDateField(controller: _dateSouhaiteeController, hint: "Date souhaitée d'intervention", prefixIcon: Icons.event_outlined, accentColor: _color, onTap: () => pickDate(context, _dateSouhaiteeController)), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _presenceConcurrente, hint: 'Présence concurrente', prefixIcon: Icons.compare_arrows_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui')), DropdownMenuItem(value: 'non', child: Text('Non'))], onChanged: (v) => setState(() => _presenceConcurrente = v!)), SizedBox(height: 14.h),
    AppTextField(controller: _detailsController, hint: 'Détails complémentaires', prefixIcon: Icons.notes_outlined, maxLines: 3, accentColor: _color),
  ]);

  Widget _phase2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const AppFormSection(title: 'Affectation', icon: Icons.engineering_outlined, color: _color), SizedBox(height: 14.h),
    AppTextField(controller: _technicienController, hint: 'Technicien affecté', prefixIcon: Icons.person_outline, accentColor: _color), SizedBox(height: 14.h),
    AppDateField(controller: _dateInterventionController, hint: "Date d'intervention prévue", prefixIcon: Icons.event_outlined, accentColor: _color, onTap: () => pickDate(context, _dateInterventionController)),
  ]);

  Widget _phase3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const AppFormSection(title: 'Résultat final', icon: Icons.check_circle_outline, color: _color), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _resultat, hint: "Résultat de l'intervention", prefixIcon: Icons.rule_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'valide', child: Text('Validé')), DropdownMenuItem(value: 'non_valide', child: Text('Non validé'))], onChanged: (v) => setState(() => _resultat = v!)), SizedBox(height: 14.h),
    AppTextField(controller: _commentaireController, hint: 'Commentaire final', prefixIcon: Icons.comment_outlined, maxLines: 3, accentColor: _color), SizedBox(height: 14.h),
    if (_resultat == 'valide') AppTextField(controller: _numeroBonController, hint: 'Numéro de bon de commande', prefixIcon: Icons.receipt_outlined, required: true, requiredMessage: 'Veuillez saisir le numéro de bon', accentColor: _color, keyboardType: TextInputType.number),
    if (_resultat == 'non_valide') AppTextField(controller: _motifRejetController, hint: 'Motif de rejet', prefixIcon: Icons.info_outline, required: true, maxLines: 3, accentColor: _color),
  ]);
}
