import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeEchantillonsForm extends ConsumerStatefulWidget {
  const DemandeEchantillonsForm({super.key});

  @override
  ConsumerState<DemandeEchantillonsForm> createState() =>
      _DemandeEchantillonsFormState();
}

class _DemandeEchantillonsFormState
    extends ConsumerState<DemandeEchantillonsForm> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  final _clientController = TextEditingController();
  final _produitController = TextEditingController();
  final _chantierController = TextEditingController();
  final _dateUtilisationController = TextEditingController();
  String? _besoinLivraison;
  final List<Map<String, TextEditingController>> _references = [
    {'ref': TextEditingController(), 'teinte': TextEditingController(), 'base': TextEditingController()}
  ];

  final _dateApplicationController = TextEditingController();
  String _produitConcurrent = 'non';
  final _nomApplicateurController = TextEditingController();

  String _resultat = 'valide';
  final _numeroBonController = TextEditingController();
  final _motifRefusController = TextEditingController();

  static const _stepTitles = ['Création', "Suivi", 'Résultat'];
  static const _stepIcons = [Icons.colorize_outlined, Icons.brush_outlined, Icons.check_circle_outline];
  static const _color = AppColors.primary;

  @override
  void dispose() {
    _pageController.dispose();
    _clientController.dispose();
    _produitController.dispose();
    _chantierController.dispose();
    _dateUtilisationController.dispose();
    for (final r in _references) { r['ref']!.dispose(); r['teinte']!.dispose(); r['base']!.dispose(); }
    _dateApplicationController.dispose();
    _nomApplicateurController.dispose();
    _numeroBonController.dispose();
    _motifRefusController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        _submit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final refs = _references.map((r) => {'reference': r['ref']!.text, 'teinte': r['teinte']!.text, 'base': r['base']!.text}).toList();
    final formData = <String, dynamic>{
      'client': _clientController.text,
      'produit': _produitController.text,
      'references': refs,
      'chantier': _chantierController.text,
      'dateUtilisation': _dateUtilisationController.text,
      'besoinLivraison': _besoinLivraison ?? '',
      'dateApplication': _dateApplicationController.text,
      'produitConcurrent': _produitConcurrent,
      'nomApplicateur': _nomApplicateurController.text,
      'resultat': _resultat,
      if (_resultat == 'valide') 'numeroBonCommande': _numeroBonController.text,
      if (_resultat == 'non_valide') 'motifRefus': _motifRefusController.text,
    };
    final demande = DemandeModel(typeDemande: 1, formData: formData);
    final success = await ref.read(demandeListProvider.notifier).createDemande(demande);
    if (!mounted) return;
    _showResult(success, "Demande créée avec succès");
    if (success) context.go(RouteNames.demandes);
  }

  void _showResult(bool success, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Text(success ? msg : ref.read(demandeListProvider).error?.message ?? 'Une erreur est survenue')]),
      backgroundColor: success ? AppColors.primary : AppColors.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(demandeListProvider.select((s) => s.isLoading));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0,
        title: Text("Demande d'échantillons", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPage(_formKeys[0], _buildPhase1()),
                _buildPage(_formKeys[1], _buildPhase2()),
                _buildPage(_formKeys[2], _buildPhase3()),
              ],
            ),
          ),
          _buildBottomNav(isLoading),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() => FormStepIndicator(current: _currentStep, total: _totalSteps, titles: _stepTitles, icons: _stepIcons, color: _color, onTap: (i) { setState(() => _currentStep = i); _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); });

  Widget _buildPage(GlobalKey<FormState> key, Widget content) =>
      SingleChildScrollView(padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h), child: Form(key: key, child: content));

  Widget _buildBottomNav(bool isLoading) => FormBottomNav(isLoading: isLoading, isLast: _currentStep == _totalSteps - 1, onBack: _prevStep, onNext: _nextStep, isFirst: _currentStep == 0, color: _color);

  Widget _buildPhase1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormSection(title: 'Informations client', icon: Icons.business_outlined, color: _color),
        _gap,
        AppTextField(controller: _clientController, hint: 'Client / revendeur concerné', prefixIcon: Icons.business_outlined, required: true, accentColor: _color),
        _gap,
        AppTextField(controller: _produitController, hint: 'Produit demandé', prefixIcon: Icons.layers_outlined, required: true, accentColor: _color),
        SizedBox(height: 24.h),
        const AppFormSection(title: 'Références (max 3)', icon: Icons.colorize_outlined, color: _color),
        _gap,
        ..._references.asMap().entries.map((e) => _buildRefCard(e.key, e.value)),
        if (_references.length < 3)
          TextButton.icon(
            onPressed: () => setState(() => _references.add({'ref': TextEditingController(), 'teinte': TextEditingController(), 'base': TextEditingController()})),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Ajouter un échantillon'),
          ),
        SizedBox(height: 24.h),
        const AppFormSection(title: 'Chantier & planning', icon: Icons.location_on_outlined, color: _color),
        _gap,
        AppTextField(controller: _chantierController, hint: 'Chantier concerné', prefixIcon: Icons.construction_outlined, accentColor: _color),
        _gap,
        AppDateField(controller: _dateUtilisationController, hint: "Date prévue d'utilisation", prefixIcon: Icons.event_outlined, accentColor: _color, onTap: () => pickDate(context, _dateUtilisationController)),
        _gap,
        AppDropdownField<String>(
          value: _besoinLivraison,
          hint: 'Besoin de livraison',
          prefixIcon: Icons.local_shipping_outlined,
          accentColor: _color,
          required: true,
          requiredMessage: 'Veuillez choisir le besoin de livraison',
          items: const [
            DropdownMenuItem(value: 'oui', child: Text('Oui')),
            DropdownMenuItem(value: 'non', child: Text('Non')),
          ],
          onChanged: (v) => setState(() => _besoinLivraison = v),
        ),
      ],
    );
  }

  Widget _buildRefCard(int index, Map<String, TextEditingController> ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 24.w, height: 24.w, decoration: const BoxDecoration(color: _color, shape: BoxShape.circle), child: Center(child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800)))),
              SizedBox(width: 8.w),
              Text('Échantillon ${index + 1}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp, color: AppColors.textPrimary)),
              const Spacer(),
              if (index > 0)
                GestureDetector(onTap: () => setState(() { ref['ref']!.dispose(); ref['teinte']!.dispose(); ref['base']!.dispose(); _references.removeAt(index); }), child: Container(padding: EdgeInsets.all(4.r), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.close, size: 14.r, color: AppColors.secondary))),
            ],
          ),
          SizedBox(height: 12.h),
          AppTextField(controller: ref['ref']!, hint: 'Référence produit', prefixIcon: Icons.qr_code_outlined, required: index == 0, accentColor: _color),
          SizedBox(height: 10.h),
          AppTextField(controller: ref['teinte']!, hint: 'Teinte', prefixIcon: Icons.palette_outlined, accentColor: _color),
          SizedBox(height: 10.h),
          AppTextField(controller: ref['base']!, hint: 'Base', prefixIcon: Icons.invert_colors_outlined, accentColor: _color),
        ],
      ),
    );
  }

  Widget _buildPhase2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormSection(title: "Suivi d'application", icon: Icons.brush_outlined, color: _color),
        _gap,
        AppDateField(controller: _dateApplicationController, hint: "Date d'application", prefixIcon: Icons.event_outlined, accentColor: _color, onTap: () => pickDate(context, _dateApplicationController)),
        _gap,
        AppDropdownField<String>(value: _produitConcurrent, hint: 'Produit concurrent présent', prefixIcon: Icons.compare_arrows_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'oui', child: Text('Oui')), DropdownMenuItem(value: 'non', child: Text('Non'))], onChanged: (v) => setState(() => _produitConcurrent = v!)),
        _gap,
        AppTextField(controller: _nomApplicateurController, hint: "Nom de l'applicateur", prefixIcon: Icons.person_outline, accentColor: _color),
      ],
    );
  }

  Widget _buildPhase3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormSection(title: 'Résultat final', icon: Icons.check_circle_outline, color: _color),
        _gap,
        AppDropdownField<String>(value: _resultat, hint: "Résultat de l'intervention", prefixIcon: Icons.rule_outlined, accentColor: _color, items: const [DropdownMenuItem(value: 'valide', child: Text('Validé')), DropdownMenuItem(value: 'non_valide', child: Text('Non validé'))], onChanged: (v) => setState(() => _resultat = v!)),
        _gap,
        if (_resultat == 'valide') AppTextField(controller: _numeroBonController, hint: 'Numéro de bon de commande', prefixIcon: Icons.receipt_outlined, required: true, requiredMessage: 'Veuillez saisir le numéro de bon', accentColor: _color, keyboardType: TextInputType.number),
        if (_resultat == 'non_valide') AppTextField(controller: _motifRefusController, hint: 'Motif du refus / non-validation', prefixIcon: Icons.info_outline, required: true, maxLines: 3, accentColor: _color),
      ],
    );
  }

  SizedBox get _gap => SizedBox(height: 14.h);
}
