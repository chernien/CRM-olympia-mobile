import 'package:equatable/equatable.dart';

/// Workflow schema for one demande type — mirrors the backend WorkflowDefinitionDto.
/// Parsed manually (no build_runner) since it is read-only, nested schema data.
class WorkflowDefinition extends Equatable {
  final int type;
  final String typeLabel;
  final List<PhaseDef> phases;

  const WorkflowDefinition({
    required this.type,
    required this.typeLabel,
    this.phases = const [],
  });

  PhaseDef? get first => phases.isNotEmpty ? phases.first : null;

  factory WorkflowDefinition.fromJson(Map<String, dynamic> json) => WorkflowDefinition(
        type: (json['type'] as num).toInt(),
        typeLabel: json['typeLabel'] as String? ?? '',
        phases: (json['phases'] as List? ?? [])
            .map((e) => PhaseDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [type];
}

/// One phase: who fills it and which fields. Mirrors PhaseDefDto.
class PhaseDef extends Equatable {
  final String key;
  final String titre;
  final String role;       // wire role, e.g. "Technicien"
  final String roleLabel;  // French label
  final List<FieldDef> champs;

  const PhaseDef({
    required this.key,
    required this.titre,
    required this.role,
    required this.roleLabel,
    this.champs = const [],
  });

  factory PhaseDef.fromJson(Map<String, dynamic> json) => PhaseDef(
        key: json['key'] as String? ?? '',
        titre: json['titre'] as String? ?? '',
        role: json['role'] as String? ?? '',
        roleLabel: json['roleLabel'] as String? ?? '',
        champs: (json['champs'] as List? ?? [])
            .map((e) => FieldDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [key];
}

/// One field. type: text | textarea | number | date | select | radio | checkbox | file | reflist.
class FieldDef extends Equatable {
  final String name;
  final String label;
  final String type;
  final bool required;

  /// ERP lookup backing this field: `'article'` | `'client'`, null for free text.
  /// Orthogonal to [type] — the control stays a text input, it just gains a
  /// suggestion list, and the stored value stays a plain string.
  final String? source;

  /// Small overline shown ABOVE the label — framing read before the question
  /// (« Confirmation », …), where [hint] is help shown under the control.
  /// Optional and purely presentational: absent from most schemas.
  final String? caption;
  final String? hint;
  final int? max;
  final List<FieldOption> options;
  final List<FieldDef> sub;

  const FieldDef({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.source,
    this.caption,
    this.hint,
    this.max,
    this.options = const [],
    this.sub = const [],
  });

  factory FieldDef.fromJson(Map<String, dynamic> json) => FieldDef(
        name: json['name'] as String? ?? '',
        label: json['label'] as String? ?? '',
        type: json['type'] as String? ?? 'text',
        required: json['required'] as bool? ?? false,
        source: json['source'] as String?,
        caption: json['caption'] as String?,
        hint: json['hint'] as String?,
        max: (json['max'] as num?)?.toInt(),
        options: (json['options'] as List? ?? [])
            .map((e) => FieldOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        sub: (json['sub'] as List? ?? [])
            .map((e) => FieldDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [name, type];
}

class FieldOption extends Equatable {
  final String value;
  final String label;

  const FieldOption({required this.value, required this.label});

  factory FieldOption.fromJson(Map<String, dynamic> json) => FieldOption(
        value: json['value'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );

  @override
  List<Object?> get props => [value];
}
