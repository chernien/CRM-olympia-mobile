import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/demande_model.dart';
import '../../viewmodels/demande_viewmodel.dart';

class DemandeFormView extends ConsumerStatefulWidget {
  const DemandeFormView({super.key});

  @override
  ConsumerState<DemandeFormView> createState() => _DemandeFormViewState();
}

class _DemandeFormViewState extends ConsumerState<DemandeFormView> {
  final _formKey = GlobalKey<FormState>();
  int _selectedType = 1;
  final Map<String, dynamic> _formData = {};

  static const _demandeTypes = [
    (1, "Demande d'échantillons"),
    (2, 'Échantillons avec application'),
    (3, 'Réclamation'),
    (4, 'Création nouveau client'),
    (5, 'Renouvellement showroom'),
    (6, 'Demande de formation'),
    (7, 'Assistance chantier'),
    (8, 'Machine à teinter'),
    (9, 'Accessoires marketing'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final demande = DemandeModel(
      typeDemande: _selectedType,
      formData: _formData,
    );

    final success =
        await ref.read(demandeListProvider.notifier).createDemande(demande);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande créée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Demande')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type selector
                DropdownButtonFormField<int>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type de demande',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _demandeTypes
                      .map((t) => DropdownMenuItem(
                            value: t.$1,
                            child: Text(t.$2),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
                const SizedBox(height: 24),

                // Dynamic form fields based on type
                _buildDynamicFields(),

                const SizedBox(height: 16),

                // Commentaire
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire (optionnel)',
                    alignLabelWithHint: true,
                  ),
                  onSaved: (v) => _formData['commentaire'] = v,
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
                        : const Text('Soumettre la demande'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    // TODO: Build specific form fields for each of the 9 demande types
    // Each type will have its own set of fields as per the cahier des charges
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Code client'),
          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          onSaved: (v) => _formData['codeClient'] = v,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          onSaved: (v) => _formData['description'] = v,
        ),
      ],
    );
  }
}
