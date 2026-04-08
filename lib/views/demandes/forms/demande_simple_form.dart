import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/demande_model.dart';
import '../../../viewmodels/demande_viewmodel.dart';
import '../../shared/widgets/app_fields.dart';

class DemandeSimpleForm extends ConsumerStatefulWidget {
  final int type;
  final String title;

  const DemandeSimpleForm({super.key, required this.type, required this.title});

  @override
  ConsumerState<DemandeSimpleForm> createState() => _DemandeSimpleFormState();
}

class _DemandeSimpleFormState extends ConsumerState<DemandeSimpleForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _chantierController = TextEditingController();
  final _dateSouhaiteeController = TextEditingController();
  final _commentaireController = TextEditingController();

  @override
  void dispose() {
    _clientController.dispose();
    _descriptionController.dispose();
    _quantiteController.dispose();
    _chantierController.dispose();
    _dateSouhaiteeController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final formData = <String, dynamic>{
      'client': _clientController.text,
      'description': _descriptionController.text,
      'quantite': _quantiteController.text,
      'chantier': _chantierController.text,
      'dateSouhaitee': _dateSouhaiteeController.text,
      'commentaire': _commentaireController.text,
    };
    final demande = DemandeModel(typeDemande: widget.type, formData: formData);
    final success = await ref.read(demandeListProvider.notifier).createDemande(demande);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: Colors.white),
        const SizedBox(width: 8),
        Text(success ? 'Demande créée avec succès' : ref.read(demandeListProvider).error?.message ?? 'Une erreur est survenue'),
      ]),
      backgroundColor: success ? AppColors.primary : AppColors.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    if (success) context.go(RouteNames.demandes);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(demandeListProvider.select((s) => s.isLoading));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0,
        title: Text(widget.title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppFormSection(title: 'Client concerné', icon: Icons.business_outlined),
                      SizedBox(height: 14.h),
                      AppTextField(controller: _clientController, hint: 'Client concerné', prefixIcon: Icons.business_outlined, required: true, requiredMessage: 'Veuillez renseigner le client concerné'),
                      SizedBox(height: 24.h),
                      const AppFormSection(title: 'Détails de la demande', icon: Icons.description_outlined),
                      SizedBox(height: 14.h),
                      AppTextField(controller: _descriptionController, hint: 'Description / besoin', prefixIcon: Icons.notes_outlined, required: true, requiredMessage: 'Veuillez renseigner la description / besoin', maxLines: 4),
                      SizedBox(height: 14.h),
                      AppTextField(controller: _quantiteController, hint: 'Quantité', prefixIcon: Icons.inventory_2_outlined, keyboardType: TextInputType.number),
                      SizedBox(height: 24.h),
                      const AppFormSection(title: 'Chantier & planning', icon: Icons.location_on_outlined),
                      SizedBox(height: 14.h),
                      AppTextField(controller: _chantierController, hint: 'Chantier concerné', prefixIcon: Icons.location_on_outlined),
                      SizedBox(height: 14.h),
                      AppDateField(controller: _dateSouhaiteeController, hint: 'Date souhaitée', prefixIcon: Icons.event_outlined, onTap: () => pickDate(context, _dateSouhaiteeController)),
                      SizedBox(height: 24.h),
                      const AppFormSection(title: 'Commentaire', icon: Icons.comment_outlined),
                      SizedBox(height: 14.h),
                      AppTextField(controller: _commentaireController, hint: 'Commentaire (optionnel)', prefixIcon: Icons.comment_outlined, maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed submit button
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: isLoading ? null : _submit,
                    child: Center(
                      child: isLoading
                          ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Soumettre la demande', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                                SizedBox(width: 8.w),
                                Icon(Icons.send_rounded, size: 16.r, color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
