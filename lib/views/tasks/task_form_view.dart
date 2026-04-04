import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';

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
  DateTime _datePrevue = DateTime.now().add(const Duration(days: 1));
  String _priorite = 'normale';

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
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Tâche')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Code client
                TextFormField(
                  controller: _codeClientController,
                  decoration: const InputDecoration(
                    labelText: 'Code client',
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Nom client
                TextFormField(
                  controller: _nomClientController,
                  decoration: const InputDecoration(
                    labelText: 'Nom client',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Adresse
                TextFormField(
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Date prévue
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date prévue'),
                  subtitle: Text(
                    '${_datePrevue.day}/${_datePrevue.month}/${_datePrevue.year}',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _datePrevue,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _datePrevue = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Priorité
                DropdownButtonFormField<String>(
                  initialValue: _priorite,
                  decoration: const InputDecoration(
                    labelText: 'Priorité',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'normale', child: Text('Normale')),
                    DropdownMenuItem(value: 'haute', child: Text('Haute')),
                    DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _priorite = v);
                  },
                ),
                const SizedBox(height: 32),

                // Error
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.error!.message,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),

                // Submit
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Soumettre la tâche'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
