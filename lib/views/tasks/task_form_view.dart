import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/activite_model.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../demandes/widgets/dynamic_form.dart';
import '../shared/widgets/app_fields.dart';

class TaskFormView extends ConsumerStatefulWidget {
  const TaskFormView({super.key});

  @override
  ConsumerState<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends ConsumerState<TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  /// Activité choisie. Tant qu'elle est nulle, il n'y a aucun champ à saisir :
  /// c'est le type qui décide du formulaire.
  ActiviteDef? _activite;

  /// Valeurs des champs dynamiques de l'activité courante.
  Map<String, dynamic> _valeurs = {};

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Feedback goes through the SnackBar, like every other flow in the app —
  /// this screen was the only one using a floating toast.
  void _snack(String msg, {required bool ok, ScaffoldMessengerState? messenger}) {
    (messenger ?? ScaffoldMessenger.of(context))
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white),
          SizedBox(width: 8.w),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ));
  }

  Future<void> _submit() async {
    final activite = _activite;
    if (activite == null) {
      _snack("Veuillez choisir un type d'activité", ok: false);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // Le nom du client vient du champ que l'activité désigne — le serveur fait
    // le même calcul, on l'envoie seulement pour que la liste soit juste avant
    // même le rechargement.
    final nomClient = activite.clientField != null
        ? (_valeurs[activite.clientField] as String? ?? '')
        : '';

    final task = TaskModel(
      codeClient: '',
      nomClient: nomClient,
      description: _descriptionController.text.trim(),
      typeActivite: activite.type,
      fields: _valeurs,
    );

    // Captured before the pop so the confirmation lands on the list we return
    // to, rather than on a context that is about to be torn down.
    final messenger = ScaffoldMessenger.of(context);

    final success = await ref.read(taskListProvider.notifier).createTask(task);

    if (success && mounted) {
      context.pop();
      _snack('Tâche enregistrée comme réalisée',
          ok: true, messenger: messenger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting =
        ref.watch(taskListProvider.select((s) => s.isSubmitting));
    final error = ref.watch(taskListProvider.select((s) => s.error));
    final activitesAsync = ref.watch(activitesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
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
                      // Each field keeps a visible label: the names used to live
                      // in the placeholders and vanish as soon as you typed.
                      // 1) Le TYPE d'abord : c'est lui qui décide des champs à
                      //    saisir, et c'est lui qui rattache l'activité au KPI.
                      activitesAsync.when(
                        loading: () => Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(
                              child: CircularProgressIndicator.adaptive()),
                        ),
                        error: (e, s) => _objectifBanner(
                          "Impossible de charger les types d'activité. Réessayez.",
                          AppColors.error,
                        ),
                        data: (activites) {
                          if (activites.isEmpty) {
                            return _objectifBanner(
                              "Aucun type d'activité disponible. Vérifiez votre "
                              "connexion puis rouvrez cet écran.",
                              AppColors.warning,
                            );
                          }
                          return _labelled(
                            "Type d'activité",
                            AppDropdownField<String>(
                              value: _activite?.type,
                              hint: 'Ex. Visite revendeur',
                              prefixIcon: Icons.category_outlined,
                              requiredMessage:
                                  "Veuillez choisir un type d'activité",
                              items: activites
                                  .map((a) => DropdownMenuItem(
                                        value: a.type,
                                        child: Text(a.typeLabel,
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              // Changer de type repart d'un formulaire vierge :
                              // conserver les valeurs enverrait au serveur des
                              // champs qui n'appartiennent pas au nouveau type.
                              onChanged: (v) => setState(() {
                                _activite = activites
                                    .where((a) => a.type == v)
                                    .firstOrNull;
                                _valeurs = {};
                              }),
                            ),
                          );
                        },
                      ),
                      // 2) Les champs du type choisi, rendus par le même
                      //    DynamicForm que les demandes.
                      if (_activite != null) ...[
                        SizedBox(height: 18.h),
                        DynamicForm(
                          champs: _activite!.champs,
                          values: _valeurs,
                          onChanged: (v) => setState(() => _valeurs = v),
                        ),
                      ],
                      SizedBox(height: 18.h),
                      // 3) Commentaire, commun aux 7 types — demandé par le
                      //    client pour pouvoir recouper le suivi des actions.
                      _labelled(
                        'Commentaire',
                        AppTextField(
                          controller: _descriptionController,
                          hint: "Ce qui a été fait pendant l'activité",
                          maxLines: 4,
                        ),
                        optional: true,
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
                                  color: AppColors.textMuted),
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

  /// Persistent field label. `optional: true` marks the field explicitly, so
  /// "(optionnel)" no longer has to hide inside a disappearing placeholder.
  Widget _labelled(String label, Widget field, {bool optional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              if (optional) ...[
                SizedBox(width: 6.w),
                Text(
                  'facultatif',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        field,
      ],
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
