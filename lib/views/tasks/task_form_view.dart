import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../shared/widgets/app_fields.dart';

class TaskFormView extends ConsumerStatefulWidget {
  const TaskFormView({super.key});

  @override
  ConsumerState<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends ConsumerState<TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  final _codeClientController = TextEditingController();
  final _nomClientController = TextEditingController();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _objectifId; // selected task objective (required)

  @override
  void dispose() {
    _codeClientController.dispose();
    _nomClientController.dispose();
    _adresseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_objectifId == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez sélectionner un objectif',
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
      return;
    }

    final task = TaskModel(
      codeClient: _codeClientController.text.trim(),
      nomClient: _nomClientController.text.trim(),
      adresse: _adresseController.text.trim().isEmpty
          ? null
          : _adresseController.text.trim(),
      description: _descriptionController.text.trim(),
      objectifId: _objectifId,
    );

    final success = await ref.read(taskListProvider.notifier).createTask(task);

    if (success && mounted) {
      Fluttertoast.showToast(
        msg: 'Tâche enregistrée (réalisée)',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting =
        ref.watch(taskListProvider.select((s) => s.isSubmitting));
    final error = ref.watch(taskListProvider.select((s) => s.error));
    final objectifsAsync = ref.watch(taskObjectifsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Tâche')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _codeClientController,
                        hint: 'Code client',
                        prefixIcon: Icons.search,
                        required: true,
                        requiredMessage:
                            'Veuillez renseigner le code client',
                      ),
                      SizedBox(height: 14.h),
                      AppTextField(
                        controller: _nomClientController,
                        hint: 'Nom client',
                        prefixIcon: Icons.person_outline,
                        required: true,
                        requiredMessage:
                            'Veuillez renseigner le nom client',
                      ),
                      SizedBox(height: 14.h),
                      AppTextField(
                        controller: _adresseController,
                        hint: 'Adresse (optionnel)',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 14.h),
                      AppTextField(
                        controller: _descriptionController,
                        hint: 'Description (optionnel)',
                        maxLines: 4,
                      ),
                      SizedBox(height: 14.h),
                      // Objectif selector (task-type objectives set by the admin).
                      objectifsAsync.when(
                        loading: () => Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                              child: CircularProgressIndicator()),
                        ),
                        error: (e, s) => _objectifBanner(
                          'Impossible de charger les objectifs. Réessayez.',
                          AppColors.error,
                        ),
                        data: (objectifs) {
                          if (objectifs.isEmpty) {
                            return _objectifBanner(
                              "Aucun objectif de type tâche n'a été défini par "
                              "l'administrateur. Impossible de créer une tâche.",
                              AppColors.warning,
                            );
                          }
                          return AppDropdownField<String>(
                            value: _objectifId,
                            hint: 'Objectif (ex. Visite client)',
                            prefixIcon: Icons.flag_outlined,
                            requiredMessage:
                                'Veuillez sélectionner un objectif',
                            items: objectifs
                                .map((o) => DropdownMenuItem(
                                      value: o.id,
                                      child: Text(
                                        o.titre.isNotEmpty
                                            ? o.titre
                                            : 'Objectif ${o.isMensuel ? "mensuel" : "trimestriel"}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _objectifId = v),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      // Info: the task date is its creation time; auto "realisée".
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 15.r, color: AppColors.textSecondary),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'La date de la tâche est sa date de création. '
                              'Elle est automatiquement marquée « Réalisée ».',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      if (error != null) ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: AppColors.error, size: 16.r),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                error.message,
                                style: TextStyle(
                                    color: AppColors.error, fontSize: 13.sp),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Enregistrer la tâche',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _objectifBanner(String message, Color color) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12.sp, color: color)),
          ),
        ],
      ),
    );
  }
}
