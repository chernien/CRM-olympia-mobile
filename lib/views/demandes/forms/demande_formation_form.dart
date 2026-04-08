import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeFormationForm extends ConsumerStatefulWidget {
  const DemandeFormationForm({super.key});
  @override
  ConsumerState<DemandeFormationForm> createState() => _DemandeFormationFormState();
}

class _DemandeFormationFormState extends ConsumerState<DemandeFormationForm> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  final _clientController = TextEditingController();
  String _typeFormation = 'revendeur';
  final _themeController = TextEditingController();
  final _nombreParticipantsController = TextEditingController();
  final _dateSouhaiteeController = TextEditingController();
  final _lieuController = TextEditingController();
  String _besoinMateriel = 'non';
  String _besoinMarketing = 'non';
  String _besoinFormateur = 'non';
  String _niveau = 'debutant';
  final _objectifController = TextEditingController();

  String _validationResponsable = 'en_attente';
  final _dateRetenueController = TextEditingController();
  final _formateurController = TextEditingController();
  final _commentairesOrganisationController = TextEditingController();

  final _compteRenduController = TextEditingController();
  final _nombreReelParticipantsController = TextEditingController();
  final _evaluationController = TextEditingController();

  static const _stepTitles = ['Création', 'Planification', 'Clôture'];
  static const _stepIcons = [Icons.school_outlined, Icons.event_note_outlined, Icons.check_circle_outline];
  static const _color = AppColors.secondary;

  @override
  void dispose() {
    _pageController.dispose(); _clientController.dispose(); _themeController.dispose();
    _nombreParticipantsController.dispose(); _dateSouhaiteeController.dispose(); _lieuController.dispose();
    _objectifController.dispose(); _dateRetenueController.dispose(); _formateurController.dispose();
    _commentairesOrganisationController.dispose(); _compteRenduController.dispose();
    _nombreReelParticipantsController.dispose(); _evaluationController.dispose();
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
    final formData = <String, dynamic>{'client': _clientController.text, 'typeFormation': _typeFormation, 'theme': _themeController.text, 'nombreParticipants': _nombreParticipantsController.text, 'dateSouhaitee': _dateSouhaiteeController.text, 'lieu': _lieuController.text, 'besoinMateriel': _besoinMateriel, 'besoinMarketing': _besoinMarketing, 'besoinFormateur': _besoinFormateur, 'niveau': _niveau, 'objectif': _objectifController.text, 'validationResponsable': _validationResponsable, 'dateRetenue': _dateRetenueController.text, 'formateurAffecte': _formateurController.text, 'commentairesOrganisation': _commentairesOrganisationController.text, 'compteRendu': _compteRenduController.text, 'nombreReelParticipants': _nombreReelParticipantsController.text, 'evaluation': _evaluationController.text};
    final demande = DemandeModel(typeDemande: 6, formData: formData);
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
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, title: Text('Demande de formation', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), foregroundColor: AppColors.textPrimary),
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
    const AppFormSection(title: 'Informations générales', icon: Icons.business_outlined, color: _color), SizedBox(height: 14.h),
    AppTextField(controller: _clientController, hint: 'Client / groupe concerné', prefixIcon: Icons.business_outlined, required: true, accentColor: _color), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _typeFormation, hint: 'Type de formation', prefixIcon: Icons.category_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'revendeur', child: Text('Revendeur')), DropdownMenuItem(value: 'applicateur', child: Text('Applicateur')), DropdownMenuItem(value: 'equipe_interne', child: Text('Équipe interne')), DropdownMenuItem(value: 'autre', child: Text('Autre'))], onChanged: (v) => setState(() => _typeFormation = v!)), SizedBox(height: 14.h),
    AppTextField(controller: _themeController, hint: 'Thème de la formation', prefixIcon: Icons.topic_outlined, required: true, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _nombreParticipantsController, hint: 'Nombre de participants', prefixIcon: Icons.group_outlined, required: true, requiredMessage: 'Veuillez saisir le nombre de participants', accentColor: _color, keyboardType: TextInputType.number), SizedBox(height: 14.h),
    AppDateField(controller: _dateSouhaiteeController, hint: 'Date souhaitée', prefixIcon: Icons.event_outlined, accentColor: _color, onTap: () => pickDate(context, _dateSouhaiteeController)), SizedBox(height: 14.h),
    AppTextField(controller: _lieuController, hint: 'Lieu', prefixIcon: Icons.location_on_outlined, accentColor: _color),
    SizedBox(height: 24.h),
    const AppFormSection(title: 'Besoins logistiques', icon: Icons.checklist_outlined, color: _color), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _besoinMateriel, hint: 'Besoin en matériel', prefixIcon: Icons.inventory_2_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui')), DropdownMenuItem(value: 'non', child: Text('Non'))], onChanged: (v) => setState(() => _besoinMateriel = v!)), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _besoinMarketing, hint: 'Supports marketing', prefixIcon: Icons.campaign_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui')), DropdownMenuItem(value: 'non', child: Text('Non'))], onChanged: (v) => setState(() => _besoinMarketing = v!)), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _besoinFormateur, hint: 'Formateur technique', prefixIcon: Icons.engineering_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui')), DropdownMenuItem(value: 'non', child: Text('Non'))], onChanged: (v) => setState(() => _besoinFormateur = v!)), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _niveau, hint: 'Niveau des participants', prefixIcon: Icons.bar_chart_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'debutant', child: Text('Débutant')), DropdownMenuItem(value: 'intermediaire', child: Text('Intermédiaire')), DropdownMenuItem(value: 'avance', child: Text('Avancé'))], onChanged: (v) => setState(() => _niveau = v!)), SizedBox(height: 14.h),
    AppTextField(controller: _objectifController, hint: 'Objectif de la formation', prefixIcon: Icons.flag_outlined, maxLines: 3, accentColor: _color),
  ]);

  Widget _phase2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const AppFormSection(title: 'Validation et organisation', icon: Icons.event_note_outlined, color: _color), SizedBox(height: 14.h),
    AppDropdownField<String>(value: _validationResponsable, hint: 'Validation responsable', prefixIcon: Icons.fact_check_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'en_attente', child: Text('En attente')), DropdownMenuItem(value: 'approuve', child: Text('Approuvé')), DropdownMenuItem(value: 'refuse', child: Text('Refusé'))], onChanged: (v) => setState(() => _validationResponsable = v!)), SizedBox(height: 14.h),
    AppDateField(controller: _dateRetenueController, hint: 'Date retenue', prefixIcon: Icons.event_available_outlined, accentColor: _color, onTap: () => pickDate(context, _dateRetenueController)), SizedBox(height: 14.h),
    AppTextField(controller: _formateurController, hint: 'Formateur affecté', prefixIcon: Icons.person_outline, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _commentairesOrganisationController, hint: "Commentaires d'organisation", prefixIcon: Icons.notes_outlined, maxLines: 3, accentColor: _color),
  ]);

  Widget _phase3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const AppFormSection(title: 'Clôture et évaluation', icon: Icons.check_circle_outline, color: _color), SizedBox(height: 14.h),
    AppTextField(controller: _compteRenduController, hint: 'Compte rendu après réalisation', prefixIcon: Icons.summarize_outlined, maxLines: 4, accentColor: _color), SizedBox(height: 14.h),
    AppTextField(controller: _nombreReelParticipantsController, hint: 'Nombre réel de participants', prefixIcon: Icons.group_outlined, accentColor: _color, keyboardType: TextInputType.number), SizedBox(height: 14.h),
    AppTextField(controller: _evaluationController, hint: 'Résultat / évaluation', prefixIcon: Icons.star_outline, maxLines: 3, accentColor: _color),
  ]);
}
