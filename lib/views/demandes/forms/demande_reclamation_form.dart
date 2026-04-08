import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeReclamationForm extends ConsumerStatefulWidget {
  const DemandeReclamationForm({super.key});

  @override
  ConsumerState<DemandeReclamationForm> createState() => _DemandeReclamationFormState();
}

class _DemandeReclamationFormState extends ConsumerState<DemandeReclamationForm> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  final _clientController = TextEditingController();
  final _revendeurController = TextEditingController();
  final _produitController = TextEditingController();
  final _numeroLotController = TextEditingController();
  final _dateAchatController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _problemeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _lieeA = 'produit';
  final _chantierController = TextEditingController();
  final _adresseChantierController = TextEditingController();
  String _echantillonRecupere = 'non';

  final _technicienController = TextEditingController();
  final _conclusionController = TextEditingController();
  String _reclamationFondee = 'oui';

  final _dateDecisionController = TextEditingController();
  String _actionDecidee = 'remplacement';
  final _detailsActionController = TextEditingController();

  final _dateCloturController = TextEditingController();
  final _commentaireController = TextEditingController();

  static const _stepTitles = ['Réclamation', 'Technique', 'Décision', 'Clôture'];
  static const _stepIcons = [Icons.report_problem_outlined, Icons.engineering_outlined, Icons.gavel_outlined, Icons.lock_outline];
  static const _color = AppColors.secondary;

  @override
  void dispose() {
    _pageController.dispose();
    _clientController.dispose(); _revendeurController.dispose(); _produitController.dispose();
    _numeroLotController.dispose(); _dateAchatController.dispose(); _quantiteController.dispose();
    _problemeController.dispose(); _descriptionController.dispose(); _chantierController.dispose();
    _adresseChantierController.dispose(); _technicienController.dispose(); _conclusionController.dispose();
    _dateDecisionController.dispose(); _detailsActionController.dispose(); _dateCloturController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else { _submit(); }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else { context.pop(); }
  }

  Future<void> _submit() async {
    final formData = <String, dynamic>{
      'client': _clientController.text, 'revendeur': _revendeurController.text,
      'produitReclame': _produitController.text, 'numeroLot': _numeroLotController.text,
      'dateAchat': _dateAchatController.text, 'quantite': _quantiteController.text,
      'probleme': _problemeController.text, 'description': _descriptionController.text,
      'lieeA': _lieeA, 'chantier': _chantierController.text,
      'adresseChantier': _adresseChantierController.text, 'echantillonRecupere': _echantillonRecupere,
      'technicien': _technicienController.text, 'conclusionTechnique': _conclusionController.text,
      'reclamationFondee': _reclamationFondee, 'dateDecision': _dateDecisionController.text,
      'actionDecidee': _actionDecidee, 'detailsAction': _detailsActionController.text,
      'dateClotureEffective': _dateCloturController.text, 'commentaireFinal': _commentaireController.text,
    };
    final demande = DemandeModel(typeDemande: 3, formData: formData);
    final success = await ref.read(demandeListProvider.notifier).createDemande(demande);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Text(success ? 'Réclamation créée avec succès' : ref.read(demandeListProvider).error?.message ?? 'Une erreur est survenue')]),
      backgroundColor: success ? AppColors.primary : AppColors.secondary,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    if (success) context.go(RouteNames.demandes);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(demandeListProvider.select((s) => s.isLoading));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, title: Text('Réclamation', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), foregroundColor: AppColors.textPrimary),
      body: Column(
        children: [
          FormStepIndicator(current: _currentStep, total: _totalSteps, titles: _stepTitles, icons: _stepIcons, color: _color, onTap: (i) { setState(() => _currentStep = i); _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }),
          Expanded(
            child: PageView(
              controller: _pageController, physics: const NeverScrollableScrollPhysics(),
              children: [
                _page(_formKeys[0], _phase1()),
                _page(_formKeys[1], _phase2()),
                _page(_formKeys[2], _phase3()),
                _page(_formKeys[3], _phase4()),
              ],
            ),
          ),
          FormBottomNav(isLoading: isLoading, isLast: _currentStep == _totalSteps - 1, isFirst: _currentStep == 0, onBack: _prevStep, onNext: _nextStep, color: _color),
        ],
      ),
    );
  }

  Widget _page(GlobalKey<FormState> key, Widget content) =>
      SingleChildScrollView(padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h), child: Form(key: key, child: content));

  Widget _phase1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppFormSection(title: 'Parties concernées', icon: Icons.people_outline, color: _color),
      _gap,
      AppTextField(controller: _clientController, hint: 'Client concerné', prefixIcon: Icons.business_outlined, required: true, accentColor: _color),
      _gap,
      AppTextField(controller: _revendeurController, hint: 'Revendeur concerné', prefixIcon: Icons.store_outlined, accentColor: _color),
      SizedBox(height: 24.h),
      const AppFormSection(title: 'Produit réclamé', icon: Icons.layers_outlined, color: _color),
      _gap,
      AppTextField(controller: _produitController, hint: 'Produit réclamé', prefixIcon: Icons.layers_outlined, required: true, accentColor: _color),
      _gap,
      AppTextField(controller: _numeroLotController, hint: 'Numéro de lot', prefixIcon: Icons.numbers_outlined, accentColor: _color, keyboardType: TextInputType.number),
      _gap,
      AppDateField(controller: _dateAchatController, hint: "Date d'achat", prefixIcon: Icons.event_outlined, accentColor: _color, onTap: () => pickDate(context, _dateAchatController)),
      _gap,
      AppTextField(controller: _quantiteController, hint: 'Quantité concernée', prefixIcon: Icons.inventory_2_outlined, required: true, requiredMessage: 'Veuillez saisir la quantité concernée', accentColor: _color, keyboardType: TextInputType.number),
      SizedBox(height: 24.h),
      const AppFormSection(title: 'Problème signalé', icon: Icons.report_problem_outlined, color: _color),
      _gap,
      AppTextField(controller: _problemeController, hint: 'Problème réclamé', prefixIcon: Icons.warning_amber_outlined, required: true, accentColor: _color),
      _gap,
      AppTextField(controller: _descriptionController, hint: 'Description détaillée', prefixIcon: Icons.notes_outlined, required: true, maxLines: 4, accentColor: _color),
      _gap,
      AppDropdownField<String>(value: _lieeA, hint: 'Réclamation liée à', prefixIcon: Icons.link_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'produit', child: Text('Produit')), DropdownMenuItem(value: 'teinte', child: Text('Teinte')), DropdownMenuItem(value: 'application', child: Text('Application')), DropdownMenuItem(value: 'rendement', child: Text('Rendement')), DropdownMenuItem(value: 'emballage', child: Text('Emballage')), DropdownMenuItem(value: 'autre', child: Text('Autre'))], onChanged: (v) => setState(() => _lieeA = v!)),
      SizedBox(height: 24.h),
      const AppFormSection(title: 'Chantier', icon: Icons.location_on_outlined, color: _color),
      _gap,
      AppTextField(controller: _chantierController, hint: 'Chantier concerné', prefixIcon: Icons.construction_outlined, accentColor: _color),
      _gap,
      AppTextField(controller: _adresseChantierController, hint: 'Adresse du chantier', prefixIcon: Icons.location_on_outlined, accentColor: _color),
      _gap,
      AppDropdownField<String>(value: _echantillonRecupere, hint: 'Échantillon récupéré', prefixIcon: Icons.science_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui')), DropdownMenuItem(value: 'non', child: Text('Non'))], onChanged: (v) => setState(() => _echantillonRecupere = v!)),
    ]);
  }

  Widget _phase2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppFormSection(title: 'Traitement technique', icon: Icons.engineering_outlined, color: _color),
      _gap,
      AppTextField(controller: _technicienController, hint: 'Nom du technicien affecté', prefixIcon: Icons.person_outline, required: true, accentColor: _color),
      _gap,
      AppTextField(controller: _conclusionController, hint: 'Conclusion technique', prefixIcon: Icons.summarize_outlined, required: true, maxLines: 4, accentColor: _color),
      _gap,
      AppDropdownField<String>(value: _reclamationFondee, hint: 'Réclamation fondée', prefixIcon: Icons.fact_check_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui — fondée')), DropdownMenuItem(value: 'non', child: Text('Non — non fondée'))], onChanged: (v) => setState(() => _reclamationFondee = v!)),
    ]);
  }

  Widget _phase3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppFormSection(title: 'Décision', icon: Icons.gavel_outlined, color: _color),
      _gap,
      AppDateField(controller: _dateDecisionController, hint: 'Date de décision', prefixIcon: Icons.event_outlined, required: true, accentColor: _color, onTap: () => pickDate(context, _dateDecisionController)),
      _gap,
      AppDropdownField<String>(value: _actionDecidee, hint: 'Action décidée', prefixIcon: Icons.check_circle_outline, accentColor: _color, items: const [DropdownMenuItem(value: 'remplacement', child: Text('Remplacement')), DropdownMenuItem(value: 'avoir', child: Text('Avoir')), DropdownMenuItem(value: 'remboursement', child: Text('Remboursement')), DropdownMenuItem(value: 'rejet', child: Text('Rejet')), DropdownMenuItem(value: 'correction_teinte', child: Text('Correction teinte')), DropdownMenuItem(value: 'autre', child: Text('Autre'))], onChanged: (v) => setState(() => _actionDecidee = v!)),
      _gap,
      AppTextField(controller: _detailsActionController, hint: "Détails de l'action", prefixIcon: Icons.notes_outlined, maxLines: 3, accentColor: _color),
    ]);
  }

  Widget _phase4() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppFormSection(title: 'Clôture du dossier', icon: Icons.lock_outline, color: _color),
      _gap,
      AppDateField(controller: _dateCloturController, hint: 'Date de clôture effective', prefixIcon: Icons.event_available_outlined, accentColor: _color, onTap: () => pickDate(context, _dateCloturController)),
      _gap,
      AppTextField(controller: _commentaireController, hint: 'Commentaire final', prefixIcon: Icons.comment_outlined, maxLines: 4, accentColor: _color),
    ]);
  }

  SizedBox get _gap => SizedBox(height: 14.h);
}
