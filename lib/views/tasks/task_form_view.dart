import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_constants.dart';
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
  final _datePrevueController = TextEditingController();
  DateTime _datePrevue = DateTime.now().add(const Duration(days: 1));

  // Uses AppConstants so it stays in sync with status badge + filter logic.
  String _priorite = AppConstants.priorityNormale;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void initState() {
    super.initState();
    _datePrevueController.text = _formatDate(_datePrevue);
  }

  @override
  void dispose() {
    _codeClientController.dispose();
    _nomClientController.dispose();
    _adresseController.dispose();
    _descriptionController.dispose();
    _datePrevueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final task = TaskModel(
      codeClient: _codeClientController.text.trim(),
      nomClient: _nomClientController.text.trim(),
      adresse: _adresseController.text.trim().isEmpty
          ? null
          : _adresseController.text.trim(),
      description: _descriptionController.text.trim(),
      datePrevue: _datePrevue,
      priorite: _priorite,
    );

    final success =
        await ref.read(taskListProvider.notifier).createTask(task);

    if (success && mounted) {
      Fluttertoast.showToast(
        msg: 'Tâche créée avec succès',
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
    // isSubmitting drives the button spinner — does NOT affect the list loading state.
    final isSubmitting =
        ref.watch(taskListProvider.select((s) => s.isSubmitting));
    final error = ref.watch(taskListProvider.select((s) => s.error));

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Tâche')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
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
                        hint: 'Adresse',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 14.h),
                      AppTextField(
                        controller: _descriptionController,
                        hint: 'Description',
                        maxLines: 4,
                        required: true,
                        requiredMessage:
                            'Veuillez renseigner la description',
                      ),
                      SizedBox(height: 14.h),
                      AppDateField(
                        controller: _datePrevueController,
                        hint: 'Date prévue',
                        prefixIcon: Icons.calendar_today_outlined,
                        required: true,
                        requiredMessage:
                            'Veuillez sélectionner la date prévue',
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _datePrevue,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _datePrevue = date;
                              _datePrevueController.text =
                                  _formatDate(date);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 14.h),
                      AppDropdownField<String>(
                        value: _priorite,
                        hint: 'Priorité',
                        prefixIcon: Icons.flag_outlined,
                        requiredMessage:
                            'Veuillez sélectionner la priorité',
                        items: const [
                          DropdownMenuItem(
                            value: AppConstants.priorityNormale,
                            child: Text('Normale'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.priorityHaute,
                            child: Text('Haute'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.priorityUrgente,
                            child: Text('Urgente'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _priorite = v);
                        },
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
                                  color: AppColors.error,
                                  fontSize: 13.sp,
                                ),
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
                              'Soumettre la tâche',
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
}
