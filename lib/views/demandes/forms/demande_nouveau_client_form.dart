import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeNouveauClientForm extends ConsumerStatefulWidget {
  const DemandeNouveauClientForm({super.key});
  @override
  ConsumerState<DemandeNouveauClientForm> createState() => _DemandeNouveauClientFormState();
}

class _DemandeNouveauClientFormState extends ConsumerState<DemandeNouveauClientForm> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 2;
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  final _raisonSocialeController = TextEditingController();
  final _contactController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _gouvernoratController = TextEditingController();
  final _matriculeFiscalController = TextEditingController();
  final _potentielController = TextEditingController();
  String _telephoneCountryCode = '+212';
  String _conditionsPaiement = 'comptant';
  String _validationFinance = 'en_attente';
  final _commentaireFinanceController = TextEditingController();

  static const _stepTitles = ['Informations', 'Validation'];
  static const _stepIcons = [Icons.person_add_outlined, Icons.verified_outlined];
  static const _color = AppColors.secondary;

  @override
  void dispose() {
    _pageController.dispose();
    _raisonSocialeController.dispose(); _contactController.dispose(); _telephoneController.dispose();
    _adresseController.dispose(); _gouvernoratController.dispose(); _matriculeFiscalController.dispose();
    _potentielController.dispose(); _commentaireFinanceController.dispose();
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
      'raisonSociale': _raisonSocialeController.text, 'nomContact': _contactController.text,
      'telephone': _telephoneController.text, 'adresse': _adresseController.text,
      'gouvernorat': _gouvernoratController.text, 'matriculeFiscal': _matriculeFiscalController.text,
      'potentielEstime': _potentielController.text, 'conditionsPaiement': _conditionsPaiement,
      'validationFinance': _validationFinance, 'commentaireFinance': _commentaireFinanceController.text,
    };
    final demande = DemandeModel(typeDemande: 4, formData: formData);
    final success = await ref.read(demandeListProvider.notifier).createDemande(demande);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Text(success ? 'Client créé avec succès' : ref.read(demandeListProvider).error?.message ?? 'Une erreur est survenue')]),
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
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, title: Text('Création nouveau client', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), foregroundColor: AppColors.textPrimary),
      body: Column(
        children: [
          FormStepIndicator(current: _currentStep, total: _totalSteps, titles: _stepTitles, icons: _stepIcons, color: _color, onTap: (i) { setState(() => _currentStep = i); _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }),
          Expanded(
            child: PageView(
              controller: _pageController, physics: const NeverScrollableScrollPhysics(),
              children: [
                _page(_formKeys[0], _phase1()),
                _page(_formKeys[1], _phase2()),
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
      const AppFormSection(title: 'Identité du client', icon: Icons.business_outlined, color: _color),
      SizedBox(height: 14.h),
      AppTextField(controller: _raisonSocialeController, hint: 'Raison sociale', prefixIcon: Icons.business_outlined, required: true, requiredMessage: 'Veuillez renseigner la raison sociale', accentColor: _color),
      SizedBox(height: 14.h),
      AppTextField(controller: _contactController, hint: 'Nom du contact', prefixIcon: Icons.person_outline, required: true, requiredMessage: 'Veuillez renseigner le nom du contact', accentColor: _color),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _telephoneController,
        hint: 'Téléphone',
        required: true,
        accentColor: _color,
        phoneWithCountry: true,
        countryCode: _telephoneCountryCode,
        onCountryCodeChanged: (v) => setState(() => _telephoneCountryCode = v ?? _telephoneCountryCode),
        requiredMessage: 'Téléphone requis',
      ),
      SizedBox(height: 24.h),
      const AppFormSection(title: 'Adresse', icon: Icons.location_on_outlined, color: _color),
      SizedBox(height: 14.h),
      AppTextField(controller: _adresseController, hint: 'Adresse complète', prefixIcon: Icons.home_outlined, required: true, requiredMessage: 'Veuillez renseigner l\'adresse complète', accentColor: _color),
      SizedBox(height: 14.h),
      AppTextField(controller: _gouvernoratController, hint: 'Gouvernorat / Ville', prefixIcon: Icons.location_city_outlined, required: true, requiredMessage: 'Veuillez renseigner le gouvernorat / ville', accentColor: _color),
      SizedBox(height: 24.h),
      const AppFormSection(title: 'Informations commerciales', icon: Icons.attach_money_outlined, color: _color),
      SizedBox(height: 14.h),
      AppTextField(controller: _matriculeFiscalController, hint: 'Matricule fiscal', prefixIcon: Icons.numbers_outlined, accentColor: _color),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _potentielController,
        hint: 'Potentiel estimé (TND)',
        prefixIcon: Icons.trending_up_outlined,
        accentColor: _color,
        keyboardType: TextInputType.number,
      ),
      SizedBox(height: 14.h),
      AppDropdownField<String>(value: _conditionsPaiement, hint: 'Conditions de paiement', prefixIcon: Icons.payment_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'comptant', child: Text('Comptant')), DropdownMenuItem(value: '30_jours', child: Text('30 jours')), DropdownMenuItem(value: '60_jours', child: Text('60 jours')), DropdownMenuItem(value: '90_jours', child: Text('90 jours')), DropdownMenuItem(value: 'autre', child: Text('Autre'))], onChanged: (v) => setState(() => _conditionsPaiement = v!)),
    ]);
  }

  Widget _phase2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppFormSection(title: 'Validation finance', icon: Icons.verified_outlined, color: _color),
      SizedBox(height: 6.h),
      Text('Ouverture de compte / crédit', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
      SizedBox(height: 14.h),
      AppDropdownField<String>(value: _validationFinance, hint: 'Statut de validation', prefixIcon: Icons.fact_check_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'en_attente', child: Text('En attente')), DropdownMenuItem(value: 'approuve', child: Text('Approuvé')), DropdownMenuItem(value: 'refuse', child: Text('Refusé'))], onChanged: (v) => setState(() => _validationFinance = v!)),
      SizedBox(height: 14.h),
      AppTextField(controller: _commentaireFinanceController, hint: 'Commentaire du service finance', prefixIcon: Icons.comment_outlined, maxLines: 3, accentColor: _color),
    ]);
  }
}
