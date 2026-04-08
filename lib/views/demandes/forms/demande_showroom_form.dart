import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeShowroomForm extends ConsumerStatefulWidget {
  const DemandeShowroomForm({super.key});
  @override
  ConsumerState<DemandeShowroomForm> createState() =>
      _DemandeShowroomFormState();
}

class _DemandeShowroomFormState extends ConsumerState<DemandeShowroomForm> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;
  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  final _clientController = TextEditingController();
  final _motifController = TextEditingController();
  String _typeRenouvellement = 'partiel';
  final List<String> _besoinExprime = [];
  final _etatActuelController = TextEditingController();
  String _besoinVisiteTechnique = 'non';

  final _dateVisiteController = TextEditingController();
  final _responsableController = TextEditingController();
  final _observationsController = TextEditingController();
  final _propositionController = TextEditingController();

  String _validationCommerciale = 'en_attente';
  String _validationTechnique = 'en_attente';
  final _commentaireController = TextEditingController();

  static const _besoinsOptions = [
    'Façade',
    'Agencement',
    'Peinture',
    'Signalétique',
    'PLV',
    'Nuanciers',
    'Autre',
  ];
  static const _stepTitles = ['Demande', 'Étude', 'Validation'];
  static const _stepIcons = [
    Icons.store_outlined,
    Icons.search_outlined,
    Icons.verified_outlined,
  ];
  static const _color = AppColors.secondary;

  @override
  void dispose() {
    _pageController.dispose();
    _clientController.dispose();
    _motifController.dispose();
    _etatActuelController.dispose();
    _dateVisiteController.dispose();
    _responsableController.dispose();
    _observationsController.dispose();
    _propositionController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final formData = <String, dynamic>{
      'client': _clientController.text,
      'motifRenouvellement': _motifController.text,
      'typeRenouvellement': _typeRenouvellement,
      'besoinExprime': _besoinExprime,
      'etatActuel': _etatActuelController.text,
      'besoinVisiteTechnique': _besoinVisiteTechnique,
      'dateVisiteTechnique': _dateVisiteController.text,
      'responsableAffecte': _responsableController.text,
      'observations': _observationsController.text,
      'propositionRetenue': _propositionController.text,
      'validationCommerciale': _validationCommerciale,
      'validationTechnique': _validationTechnique,
      'commentaire': _commentaireController.text,
    };
    final demande = DemandeModel(typeDemande: 5, formData: formData);
    final success = await ref
        .read(demandeListProvider.notifier)
        .createDemande(demande);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              success
                  ? 'Demande créée avec succès'
                  : ref.read(demandeListProvider).error?.message ??
                        'Une erreur est survenue',
            ),
          ],
        ),
        backgroundColor: success ? AppColors.primary : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (success) context.go(RouteNames.demandes);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(demandeListProvider.select((s) => s.isLoading));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Renouvellement showroom',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          FormStepIndicator(
            current: _currentStep,
            total: _totalSteps,
            titles: _stepTitles,
            icons: _stepIcons,
            color: _color,
            onTap: (i) {
              setState(() => _currentStep = i);
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _page(_formKeys[0], _phase1()),
                _page(_formKeys[1], _phase2()),
                _page(_formKeys[2], _phase3()),
              ],
            ),
          ),
          FormBottomNav(
            isLoading: isLoading,
            isLast: _currentStep == _totalSteps - 1,
            isFirst: _currentStep == 0,
            onBack: _prevStep,
            onNext: _nextStep,
            color: _color,
          ),
        ],
      ),
    );
  }

  Widget _page(GlobalKey<FormState> key, Widget content) =>
      SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        child: Form(key: key, child: content),
      );

  Widget _phase1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppFormSection(
        title: 'Informations showroom',
        icon: Icons.store_outlined,
        color: _color,
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _clientController,
        hint: 'Client / showroom concerné',
        prefixIcon: Icons.store_outlined,
        required: true,
        requiredMessage: 'Veuillez renseigner le client / showroom concerné',
        accentColor: _color,
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _motifController,
        hint: 'Motif du renouvellement',
        prefixIcon: Icons.description_outlined,
        required: true,
        requiredMessage: 'Veuillez renseigner le motif du renouvellement',
        maxLines: 2,
        accentColor: _color,
      ),
      SizedBox(height: 14.h),
      AppDropdownField<String>(
        value: _typeRenouvellement,
        hint: 'Type de renouvellement',
        prefixIcon: Icons.refresh_outlined,
        accentColor: _color,
        items: const [
          DropdownMenuItem(value: 'partiel', child: Text('Partiel')),
          DropdownMenuItem(value: 'total', child: Text('Total')),
        ],
        onChanged: (v) => setState(() => _typeRenouvellement = v!),
      ),
      SizedBox(height: 24.h),
      AppFormSection(
        title: 'Besoin exprimé',
        icon: Icons.checklist_outlined,
        color: _color,
      ),
      SizedBox(height: 12.h),
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _besoinsOptions.map((option) {
          final selected = _besoinExprime.contains(option);
          return GestureDetector(
            onTap: () => setState(() {
              if (selected) {
                _besoinExprime.remove(option);
              } else {
                _besoinExprime.add(option);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected
                    ? _color.withValues(alpha: 0.12)
                    : const Color(0xFFF4F7FC),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected ? _color : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check_rounded, size: 13.r, color: _color),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? _color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _etatActuelController,
        hint: 'État actuel du showroom',
        prefixIcon: Icons.info_outline,
        maxLines: 3,
        accentColor: _color,
      ),
      SizedBox(height: 14.h),
      AppDropdownField<String>(
        value: _besoinVisiteTechnique,
        hint: 'Besoin de visite technique',
        prefixIcon: Icons.engineering_outlined,
        accentColor: _color,
        items: const [
          DropdownMenuItem(value: 'oui', child: Text('Oui')),
          DropdownMenuItem(value: 'non', child: Text('Non')),
        ],
        onChanged: (v) => setState(() => _besoinVisiteTechnique = v!),
      ),
    ],
  );

  Widget _phase2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppFormSection(
        title: 'Étude technique',
        icon: Icons.search_outlined,
        color: _color,
      ),
      SizedBox(height: 14.h),
      AppDateField(
        controller: _dateVisiteController,
        hint: 'Date de visite technique',
        prefixIcon: Icons.event_outlined,
        accentColor: _color,
        onTap: () => pickDate(context, _dateVisiteController),
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _responsableController,
        hint: 'Responsable affecté',
        prefixIcon: Icons.person_outline,
        accentColor: _color,
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _observationsController,
        hint: 'Observations',
        prefixIcon: Icons.notes_outlined,
        maxLines: 3,
        accentColor: _color,
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _propositionController,
        hint: 'Proposition retenue',
        prefixIcon: Icons.lightbulb_outline,
        maxLines: 3,
        accentColor: _color,
      ),
    ],
  );

  Widget _phase3() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppFormSection(
        title: 'Validation finale',
        icon: Icons.verified_outlined,
        color: _color,
      ),
      SizedBox(height: 14.h),
      AppDropdownField<String>(
        value: _validationCommerciale,
        hint: 'Validation commerciale',
        prefixIcon: Icons.handshake_outlined,
        accentColor: _color,
        items: const [
          DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
          DropdownMenuItem(value: 'approuve', child: Text('Approuvé')),
          DropdownMenuItem(value: 'refuse', child: Text('Refusé')),
        ],
        onChanged: (v) => setState(() => _validationCommerciale = v!),
      ),
      SizedBox(height: 14.h),
      AppDropdownField<String>(
        value: _validationTechnique,
        hint: 'Validation technique',
        prefixIcon: Icons.engineering_outlined,
        accentColor: _color,
        items: const [
          DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
          DropdownMenuItem(value: 'approuve', child: Text('Approuvé')),
          DropdownMenuItem(value: 'refuse', child: Text('Refusé')),
        ],
        onChanged: (v) => setState(() => _validationTechnique = v!),
      ),
      SizedBox(height: 14.h),
      AppTextField(
        controller: _commentaireController,
        hint: 'Commentaire',
        prefixIcon: Icons.comment_outlined,
        maxLines: 3,
        accentColor: _color,
      ),
    ],
  );
}
