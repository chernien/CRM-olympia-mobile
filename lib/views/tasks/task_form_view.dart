import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String _priorite = 'normale';

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

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
      adresse: _adresseController.text.trim(),
      description: _descriptionController.text.trim(),
      datePrevue: _datePrevue,
      priorite: _priorite,
    );

    final success = await ref.read(taskListProvider.notifier).createTask(task);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche créée avec succès'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskListProvider);
    _datePrevueController.text = _formatDate(_datePrevue);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Tâche')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _codeClientController,
                        hint: 'Code client',
                        prefixIcon: Icons.search,
                        required: true,
                        requiredMessage: 'Veuillez renseigner le code client',
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _nomClientController,
                        hint: 'Nom client',
                        prefixIcon: Icons.person_outline,
                        required: true,
                        requiredMessage: 'Veuillez renseigner le nom client',
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _adresseController,
                        hint: 'Adresse',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _descriptionController,
                        hint: 'Description',
                        maxLines: 4,
                        required: true,
                        requiredMessage: 'Veuillez renseigner la description',
                      ),
                      const SizedBox(height: 14),
                      AppDateField(
                        controller: _datePrevueController,
                        hint: 'Date prévue',
                        prefixIcon: Icons.calendar_today_outlined,
                        required: true,
                        requiredMessage: 'Veuillez sélectionner la date prévue',
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _datePrevue,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _datePrevue = date);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      AppDropdownField<String>(
                        value: _priorite,
                        hint: 'Priorité',
                        prefixIcon: Icons.flag_outlined,
                        requiredMessage: 'Veuillez sélectionner la priorité',
                        items: const [
                          DropdownMenuItem(value: 'normale', child: Text('Normale')),
                          DropdownMenuItem(value: 'haute', child: Text('Haute')),
                          DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _priorite = v);
                        },
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          state.error!.message,
                          style: const TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: state.isLoading ? null : _submit,
                        child: Center(
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Soumettre la tâche',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
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
