import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/erp_ref_model.dart';
import '../../../models/workflow_model.dart';
import '../../../services/lookup_service.dart';
import '../../shared/widgets/app_fields.dart';

// ── Helpers shared with the callers (create / phase submit) ──────────────────

bool _isEmpty(dynamic v) =>
    v == null ||
    (v is String && v.trim().isEmpty) ||
    (v is List && v.isEmpty);

/// Labels of the required fields still empty (blocks submit).
List<String> missingRequired(List<FieldDef> champs, Map<String, dynamic> values) {
  final out = <String>[];
  for (final f in champs) {
    if (!f.required) continue;
    if (f.type == 'reflist') continue;
    if (_isEmpty(values[f.name])) out.add(f.label);
  }
  return out;
}

/// Valeurs proposées à l'OUVERTURE d'une phase, prises sur la demande elle-même
/// (schéma : [FieldDef.prefill]). Aujourd'hui un seul cas —
/// « numerocommandeerp » — qui reprend le numéro reçu de l'ERP et confirmé par
/// l'ADV, pour que la production ne le recopie pas à la main (réunion client du
/// 11/09/2026).
///
/// Le champ reste modifiable, et une demande sans numéro s'ouvre vide : un
/// prefill est une proposition, jamais une contrainte.
Map<String, dynamic> seedValues(List<FieldDef> champs, String? numeroCommande) {
  final seed = <String, dynamic>{};
  final numero = (numeroCommande ?? '').trim();
  if (numero.isEmpty) return seed;
  for (final f in champs) {
    if (f.prefill == 'numerocommandeerp') seed[f.name] = numero;
  }
  return seed;
}

/// Flattens every File field's uploaded URLs into the phase-level piecesJointes.
List<String> collectPieces(List<FieldDef> champs, Map<String, dynamic> values) {
  final urls = <String>[];
  for (final f in champs) {
    if (f.type == 'file' && values[f.name] is List) {
      urls.addAll((values[f.name] as List).cast<String>());
    }
  }
  return urls;
}

/// Splits the raw values map into `{fields}` (scalar/select/etc.) — file fields
/// are excluded because they travel in piecesJointes.
Map<String, dynamic> fieldsForSubmit(List<FieldDef> champs, Map<String, dynamic> values) {
  final out = <String, dynamic>{};
  for (final f in champs) {
    if (f.type == 'file') continue;
    final v = values[f.name];
    if (v == null) continue;
    out[f.name] = v;
  }
  return out;
}

/// Renders a phase schema (champs[]) as a form. Controlled: [values] is a
/// { fieldName: value } map, [onChanged] is called with the full updated map.
class DynamicForm extends ConsumerStatefulWidget {
  final List<FieldDef> champs;
  final Map<String, dynamic> values;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool disabled;

  const DynamicForm({
    super.key,
    required this.champs,
    required this.values,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  ConsumerState<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends ConsumerState<DynamicForm> {
  final Map<String, TextEditingController> _controllers = {};

  // Controller created once per field; its listener mirrors edits into values.
  //
  // Prend le CHAMP et non son nom : la réclamation porte la cascade TAR à plat
  // dans le formulaire, donc changer « Produit réclamé » doit vider ses deux
  // sous-références — exactement ce que fait [_rowCtrl] pour une ligne.
  TextEditingController _ctrl(FieldDef f) => _controllers.putIfAbsent(f.name, () {
        final c = TextEditingController(text: widget.values[f.name]?.toString() ?? '');
        c.addListener(() {
          if (f.source == 'articleref') {
            final next = Map<String, dynamic>.from(widget.values)..[f.name] = c.text;
            for (final other in widget.champs) {
              if (other.source == 'teinte' || other.source == 'base') next[other.name] = '';
            }
            widget.onChanged(next);
            return;
          }
          _set(f.name, c.text);
        });
        return c;
      });

  /// Controller for one cell of a RefList row. Keyed by `field#row#column` so a
  /// source-backed column can own a controller like any other text input.
  TextEditingController _rowCtrl(FieldDef f, int i, FieldDef sf) =>
      _controllers.putIfAbsent('${f.name}#$i#${sf.name}', () {
        final rows = _rows(f.name);
        final c = TextEditingController(
          text: i < rows.length ? (rows[i][sf.name]?.toString() ?? '') : '',
        );
        c.addListener(() {
          final current = _rows(f.name);
          if (i >= current.length) return;
          current[i][sf.name] = c.text;
          // Cascade TAR : changer la référence invalide la teinte et la base de
          // la même ligne — une teinte choisie pour une autre référence n'a
          // aucun sens, on la vide plutôt que de la laisser mentir.
          if (sf.source == 'articleref') {
            for (final other in f.sub) {
              if (other.source == 'teinte' || other.source == 'base') {
                current[i][other.name] = '';
              }
            }
          }
          _set(f.name, current);
        });
        return c;
      });

  List<Map<String, dynamic>> _rows(String name) => widget.values[name] is List
      ? List<Map<String, dynamic>>.from(
          (widget.values[name] as List).map((e) => Map<String, dynamic>.from(e as Map)))
      : <Map<String, dynamic>>[];

  /// Champ frère du formulaire dont la SOURCE est [sourceKind], ou null.
  /// La réclamation porte la cascade à plat là où l'échantillon la porte dans
  /// les colonnes d'une ligne : deux voisinages, un seul repérage par source.
  FieldDef? _flatCol(String sourceKind) {
    for (final f in widget.champs) {
      if (f.source == sourceKind) return f;
    }
    return null;
  }

  String _flatValue(String sourceKind) {
    final col = _flatCol(sourceKind);
    if (col == null) return '';
    return (widget.values[col.name] ?? '').toString().trim();
  }

  /// Valeur de la colonne dont la SOURCE est [sourceKind] sur la ligne [i] —
  /// la cascade TAR se repère par source, jamais par nom de champ : le schéma
  /// reste la seule vérité.
  /// Libellé de la colonne amont d'une ligne, pour nommer le champ à remplir
  /// d'abord avec les mots du formulaire courant.
  String _cascadeLabel(FieldDef f, String sourceKind) {
    for (final s in f.sub) {
      if (s.source == sourceKind) return s.label;
    }
    return '';
  }

  String _cascadeValue(FieldDef f, List<Map<String, dynamic>> rows, int i, String sourceKind) {
    if (i >= rows.length) return '';
    for (final s in f.sub) {
      if (s.source == sourceKind) return (rows[i][s.name] ?? '').toString().trim();
    }
    return '';
  }

  void _dropRowControllers(String fieldName) {
    final prefix = '$fieldName#';
    for (final key in _controllers.keys.where((k) => k.startsWith(prefix)).toList()) {
      _controllers.remove(key)?.dispose();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _set(String name, dynamic value) {
    final next = Map<String, dynamic>.from(widget.values)..[name] = value;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final f in widget.champs) ...[
          _buildField(f),
          SizedBox(height: 18.h),
        ],
      ],
    );
  }

  /// Label of a field, preceded by its optional [FieldDef.caption] — framing read
  /// BEFORE the question, where the hint is help read after the control. Rendered
  /// here so every field type inherits it; a schema without a caption is unchanged.
  Widget _label(FieldDef f) => Padding(
        padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((f.caption ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  f.caption!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            RichText(
              text: TextSpan(
                text: f.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
                children: f.required
                    ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))]
                    : null,
              ),
            ),
          ],
        ),
      );

  /// Wraps an input with its persistent label (and optional helper text).
  ///
  /// Every field type now carries a visible label. Text, number, date and
  /// select fields previously passed `hint: f.label`, so the field's name lived
  /// in the placeholder alone and disappeared the moment the user typed —
  /// leaving a column of anonymous boxes on multi-field phases.
  Widget _labelled(FieldDef f, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(f),
        input,
        if ((f.hint ?? '').isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 2.w),
            child: Text(
              f.hint!,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
            ),
          ),
      ],
    );
  }

  // `articleref` : même lookup que `article`, mais la valeur stockée est la
  // seule référence (réunion client du 10/09/2026).
  static const _searchableSources = {'client', 'article', 'articleref'};

  Widget _buildField(FieldDef f) {
    // Source 'technicien' keeps its declared control — a dropdown — and only
    // borrows the source mechanism to fill its options from the API. Technicians
    // are a few accounts; a type-ahead over them would only add a way to mistype
    // a colleague's name.
    if (f.source == 'technicien' && f.type != 'reflist') {
      return _labelled(
        f,
        TechnicienSelectField(
          value: widget.values[f.name] as String?,
          hint: f.label,
          required: f.required,
          enabled: !widget.disabled,
          onChanged: (v) => _set(f.name, v),
        ),
      );
    }
    // Cascade TAR portée à plat par la phase (réclamation) : les champs amont
    // sont les champs frères du formulaire.
    if ((f.source == 'teinte' || f.source == 'base') && f.type != 'reflist') {
      final upstream = _flatCol(f.source == 'teinte' ? 'articleref' : 'teinte');
      return _labelled(
        f,
        TarCascadeField(
          kind: f.source!,
          label: f.label,
          upstreamLabel: upstream?.label ?? '',
          refValue: _flatValue('articleref'),
          teinteValue: _flatValue('teinte'),
          value: (widget.values[f.name] ?? '').toString(),
          enabled: !widget.disabled,
          onChanged: (v) {
            final next = Map<String, dynamic>.from(widget.values)..[f.name] = v;
            if (f.source == 'teinte') {
              for (final other in widget.champs) {
                if (other.source == 'base') next[other.name] = '';
              }
            }
            widget.onChanged(next);
            setState(() {});
          },
        ),
      );
    }
    // A searchable data source wins over the raw type: still a text input, but
    // backed by an ERP suggestion list. Anything the schema does not mark keeps
    // its old widget.
    if (_searchableSources.contains(f.source) && f.type != 'reflist') {
      return _labelled(
        f,
        ErpAutocompleteField(
          controller: _ctrl(f),
          source: f.source!,
          hint: f.label,
          required: f.required,
          enabled: !widget.disabled,
        ),
      );
    }
    switch (f.type) {
      case 'textarea':
        return _labelled(
          f,
          AppTextField(
            controller: _ctrl(f),
            hint: f.label,
            maxLines: 4,
            required: f.required,
          ),
        );
      case 'number':
        return _labelled(
          f,
          AppTextField(
            controller: _ctrl(f),
            hint: f.label,
            keyboardType: TextInputType.number,
            required: f.required,
          ),
        );
      case 'date':
        return _labelled(
          f,
          AppDateField(
            controller: _ctrl(f),
            hint: f.label,
            required: f.required,
            onTap: () => pickDate(context, _ctrl(f)),
          ),
        );
      case 'time':
        return _labelled(
          f,
          AppDateField(
            controller: _ctrl(f),
            hint: f.label,
            prefixIcon: Icons.schedule_outlined,
            required: f.required,
            onTap: () => pickTime(context, _ctrl(f)),
          ),
        );
      case 'select':
        return _labelled(f, _selectField(f));
      case 'radio':
        return _chipsField(f, multi: false);
      case 'checkbox':
        return _chipsField(f, multi: true);
      case 'file':
        return _fileField(f);
      case 'reflist':
        return _refListField(f);
      case 'text':
      default:
        return _labelled(
          f,
          AppTextField(
            controller: _ctrl(f),
            hint: f.label,
            required: f.required,
          ),
        );
    }
  }

  Widget _selectField(FieldDef f) {
    final value = widget.values[f.name] as String?;
    return AppDropdownField<String>(
      value: value,
      hint: f.label,
      required: f.required,
      // A disabled select used to accept taps and silently discard them; it now
      // reads as inert.
      enabled: !widget.disabled,
      items: f.options
          .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label)))
          .toList(),
      onChanged: (v) => _set(f.name, v),
    );
  }

  Widget _chipsField(FieldDef f, {required bool multi}) {
    final selected = multi
        ? (widget.values[f.name] is List ? (widget.values[f.name] as List).cast<String>() : <String>[])
        : <String>[if (widget.values[f.name] != null) widget.values[f.name].toString()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(f),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: f.options.map((o) {
            final active = selected.contains(o.value);
            return Semantics(
              // Single-choice reads as a radio, multi-choice as a checkbox.
              inMutuallyExclusiveGroup: !multi,
              checked: active,
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                onTap: widget.disabled
                    ? null
                    : () {
                        if (multi) {
                          final next = List<String>.from(selected);
                          active ? next.remove(o.value) : next.add(o.value);
                          _set(f.name, next);
                        } else {
                          _set(f.name, o.value);
                        }
                        setState(() {});
                      },
                child: Container(
                  // 44 dp minimum — the chips were ~38 dp tall.
                  constraints: BoxConstraints(minHeight: 44.h),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    o.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _fileField(FieldDef f) {
    final urls = widget.values[f.name] is List
        ? (widget.values[f.name] as List).cast<String>()
        : <String>[];
    final max = f.max ?? 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(f),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (int i = 0; i < urls.length; i++)
              Container(
                // 44 dp minimum so the chip and its remove button are hittable.
                constraints: BoxConstraints(minHeight: 44.h),
                padding: EdgeInsets.only(left: 12.w, right: widget.disabled ? 12.w : 2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insert_drive_file_outlined, size: 15.sp, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 120.w),
                      child: Text(
                        urls[i].split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    if (!widget.disabled)
                      // Was a bare 15 dp icon — now a full-size icon button.
                      IconButton(
                        tooltip: 'Retirer le fichier',
                        visualDensity: VisualDensity.compact,
                        constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final next = List<String>.from(urls)..removeAt(i);
                          _set(f.name, next);
                        },
                        icon: Icon(Icons.close_rounded, size: 16.sp, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            if (!widget.disabled && urls.length < max)
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => _pickFiles(f, urls, max),
                child: Container(
                  constraints: BoxConstraints(minHeight: 44.h),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderStrong, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file_outlined, size: 16.sp, color: AppColors.textMuted),
                      SizedBox(width: 6.w),
                      Text('Ajouter', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (f.hint != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 2.w),
            child: Text(f.hint!, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
          ),
      ],
    );
  }

  Future<void> _pickFiles(FieldDef f, List<String> current, int max) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    final paths = result.paths.whereType<String>().take(max - current.length).toList();
    if (paths.isEmpty) return;
    final upload = ref.read(uploadServiceProvider);
    final next = List<String>.from(current);
    var echecs = 0;
    for (final p in paths) {
      final res = await upload.uploadFile(p);
      res.fold((_) => echecs++, (url) => next.add(url));
    }
    _set(f.name, next);

    // Un envoi raté était totalement muet : le technicien croyait ses photos
    // jointes — obligatoires sur une réclamation — et validait une phase sans
    // elles. On le dit, en nommant le nombre de fichiers concernés.
    if (echecs > 0 && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(echecs == 1
              ? "Le fichier n'a pas pu être envoyé. Réessayez."
              : "$echecs fichiers n'ont pas pu être envoyés. Réessayez."),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  Widget _refListField(FieldDef f) {
    final rows = widget.values[f.name] is List
        ? List<Map<String, dynamic>>.from(
            (widget.values[f.name] as List).map((e) => Map<String, dynamic>.from(e as Map)))
        : <Map<String, dynamic>>[];
    final max = f.max ?? 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(f),
        for (int i = 0; i < rows.length; i++)
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final sf in f.sub)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: sf.source == 'teinte' || sf.source == 'base'
                        ? TarCascadeField(
                            kind: sf.source!,
                            label: sf.label,
                            upstreamLabel: _cascadeLabel(
                                f, sf.source == 'teinte' ? 'articleref' : 'teinte'),
                            refValue: _cascadeValue(f, rows, i, 'articleref'),
                            teinteValue: _cascadeValue(f, rows, i, 'teinte'),
                            value: (rows[i][sf.name] ?? '').toString(),
                            enabled: !widget.disabled,
                            onChanged: (v) {
                              final current = _rows(f.name);
                              if (i >= current.length) return;
                              current[i][sf.name] = v;
                              // Changer la teinte invalide la base de la ligne.
                              if (sf.source == 'teinte') {
                                for (final other in f.sub) {
                                  if (other.source == 'base') current[i][other.name] = '';
                                }
                              }
                              _set(f.name, current);
                              setState(() {});
                            },
                          )
                        : _searchableSources.contains(sf.source)
                        ? ErpAutocompleteField(
                            controller: _rowCtrl(f, i, sf),
                            source: sf.source!,
                            hint: sf.label,
                            required: sf.required,
                            enabled: !widget.disabled,
                          )
                        : TextFormField(
                            initialValue: rows[i][sf.name]?.toString() ?? '',
                            enabled: !widget.disabled,
                            keyboardType:
                                sf.type == 'number' ? TextInputType.number : TextInputType.text,
                            decoration: InputDecoration(
                              labelText: sf.label,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                            onChanged: (v) {
                              rows[i][sf.name] = v;
                              _set(f.name, rows);
                            },
                          ),
                  ),
                if (!widget.disabled)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final next = List<Map<String, dynamic>>.from(rows)..removeAt(i);
                        // Row controllers are keyed by index; after a removal the
                        // indices shift, so drop them all and let them re-seed from
                        // the new rows.
                        _dropRowControllers(f.name);
                        _set(f.name, next);
                      },
                      icon: Icon(Icons.delete_outline, size: 16.sp, color: AppColors.error),
                      label: Text('Retirer', style: TextStyle(color: AppColors.error, fontSize: 12.sp)),
                    ),
                  ),
              ],
            ),
          ),
        if (!widget.disabled && rows.length < max)
          TextButton.icon(
            onPressed: () => _set(f.name, [...rows, <String, dynamic>{}]),
            icon: Icon(Icons.add_rounded, size: 18.sp, color: AppColors.primary),
            label: Text('Ajouter une ligne (${rows.length}/$max)',
                style: TextStyle(color: AppColors.primary, fontSize: 13.sp, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

// ─── Technicien dropdown (schema: type 'select' + source 'technicien') ───────

/// Dropdown whose options are the technicians registered in the application.
///
/// The client requires the technician to be picked among real accounts, never
/// typed — so this is a plain picker, not an autocomplete: the list is a handful
/// of rows, fetched whole once when the form opens.
///
/// Three states are surfaced rather than collapsed into an empty picker:
/// loading, load failure, and "no technician registered at all" — the last one is
/// a real situation (the admin has not created any yet) and the message says what
/// has to happen for the phase to become fillable.
///
/// The stored value is the technician's NAME, like every other source-backed
/// field, so nothing downstream has to resolve an id.
class TechnicienSelectField extends ConsumerStatefulWidget {
  final String? value;
  final String hint;
  final bool required;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const TechnicienSelectField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.required = false,
    this.enabled = true,
  });

  @override
  ConsumerState<TechnicienSelectField> createState() => _TechnicienSelectFieldState();
}

class _TechnicienSelectFieldState extends ConsumerState<TechnicienSelectField> {
  List<ErpRef> _rows = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ref.read(lookupServiceProvider).fetchTechniciens();
    if (!mounted) return;
    setState(() {
      _loading = false;
      res.fold(
        (f) { _error = f.message; _rows = const []; },
        (rows) { _error = null; _rows = rows; },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _notice('Chargement des techniciens…', AppColors.textMuted);

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _notice('Chargement des techniciens impossible.', AppColors.error),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: Text('Réessayer', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    }

    // A value already stored — an older demande, or a technician since disabled —
    // stays selectable so reopening the form does not silently blank the field.
    final names = _rows.map((r) => r.label).toList();
    final current = widget.value;
    if (current != null && current.isNotEmpty && !names.contains(current)) {
      names.insert(0, current);
    }

    if (names.isEmpty) {
      return _notice(
        "Aucun technicien n'est enregistré dans l'application. Un administrateur doit "
        "créer un compte de rôle « Technicien » avant de pouvoir affecter cette demande.",
        AppColors.warning,
      );
    }

    return AppDropdownField<String>(
      value: current,
      hint: widget.hint,
      required: widget.required,
      enabled: widget.enabled,
      items: names.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
      onChanged: widget.onChanged,
    );
  }

  Widget _notice(String text, Color color) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(text, style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
      );
}

// ─── ERP autocomplete (schema-driven: FieldDef.source) ───────────────────────

/// Text input backed by a Divalto lookup: type 2+ characters, pick from the list.
///
/// The value written to the controller — and therefore stored in the demande — is
/// a plain string (client NOM, or "REF DES" for an article). Nothing downstream has
/// to know the field was picked rather than typed, which is what keeps the older
/// free-text demandes readable in the list, detail and history screens.
///
/// The suggestion list renders INLINE under the field rather than in an overlay:
/// on a scrolling form an overlay drifts away from its anchor as soon as the
/// keyboard opens. Rows are 48 dp tall.
class ErpAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String source; // 'client' | 'article'
  final String hint;
  final bool required;
  final bool enabled;

  const ErpAutocompleteField({
    super.key,
    required this.controller,
    required this.source,
    required this.hint,
    this.required = false,
    this.enabled = true,
  });

  @override
  ConsumerState<ErpAutocompleteField> createState() => _ErpAutocompleteFieldState();
}

class _ErpAutocompleteFieldState extends ConsumerState<ErpAutocompleteField> {
  static const _debounce = Duration(milliseconds: 300);

  List<ErpRef> _results = const [];
  bool _open = false;
  bool _loading = false;
  bool _searched = false;
  /// Mode « parcourir » : la liste est ouverte PAR LE BOUTON, sans saisie — le
  /// commercial qui ne connaît pas ses clients ouvre et choisit (réunion client
  /// du 10/09/2026). Taper une lettre rebascule en mode recherche.
  bool _browsing = false;
  /// Vrai quand la dernière recherche a ÉCHOUÉ (réseau, serveur), par opposition
  /// à une recherche qui a abouti sans résultat. Les deux affichaient le même
  /// « Aucun article trouvé » — un commercial hors couverture en concluait que le
  /// produit n'existe pas, et retapait sans fin.
  bool _enEchec = false;
  String _lastQuery = '';
  // Incremented on every keystroke; a late response with a stale token is dropped,
  // so a slow "ANT" can never overwrite the results of "ANTICA".
  int _token = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTyped);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTyped);
    super.dispose();
  }

  void _onTyped() {
    final q = widget.controller.text.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;
    _browsing = false; // taper une lettre rebascule en mode recherche
    final mine = ++_token;

    if (q.length < LookupService.minQueryLength) {
      setState(() {
        _open = false;
        _loading = false;
        _searched = false;
        _enEchec = false;
        _results = const [];
      });
      return;
    }

    setState(() {
      _open = true;
      _loading = true;
    });

    Future.delayed(_debounce, () async {
      if (!mounted || _token != mine) return;
      final res = await ref.read(lookupServiceProvider).searchBySource(widget.source, q);
      if (!mounted || _token != mine) return;
      setState(() {
        _results = res.getOrElse(() => const <ErpRef>[]);
        _enEchec = res.isLeft();
        _loading = false;
        _searched = true;
      });
    });
  }

  void _select(ErpRef row) {
    _token++; // cancel anything in flight
    // La source `articleref` STOCKE la référence seule ([ErpRef.code]) ; la
    // suggestion affichait « REF DES » pour que le produit soit reconnaissable.
    final stored = widget.source == 'articleref' ? (row.code ?? row.label) : row.label;
    _lastQuery = stored.trim();
    widget.controller.value = TextEditingValue(
      text: stored,
      selection: TextSelection.collapsed(offset: stored.length),
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _open = false;
      _browsing = false;
      _loading = false;
      _results = const [];
    });
  }

  /// Ouvre la liste complète sans saisie ; re-taper referme via [_onTyped].
  Future<void> _toggleBrowse() async {
    if (!widget.enabled) return;
    if (_open && _browsing) {
      setState(() { _open = false; _browsing = false; });
      return;
    }
    final mine = ++_token;
    setState(() {
      _browsing = true;
      _open = true;
      _loading = true;
      _results = const [];
    });
    final res = await ref.read(lookupServiceProvider).browseBySource(widget.source);
    if (!mounted || _token != mine) return;
    setState(() {
      _results = res.getOrElse(() => const <ErpRef>[]);
      _enEchec = res.isLeft();
      _loading = false;
      _searched = true;
    });
  }

  String get _emptyLabel =>
      widget.source == 'client' ? 'Aucun client trouvé' : 'Aucun article trouvé';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          canRequestFocus: false,
          onFocusChange: (has) {
            // Collapse when the field loses focus — a list left hanging under an
            // unfocused field steals taps from the fields below it. Le mode
            // « parcourir » s'ouvre SANS focus : il se ferme par le bouton ou
            // par un choix, pas par un événement de focus qu'il n'aura jamais.
            if (!has && _open && !_browsing) setState(() => _open = false);
          },
          child: AppTextField(
            controller: widget.controller,
            hint: widget.hint,
            required: widget.required,
            readOnly: !widget.enabled,
            // Client et produit se saisissent en capitales, comme les données ERP.
            inputFormatters: const [UpperCaseTextFormatter()],
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loading)
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                // Bouton « ouvrir la liste » : parcourir sans taper (réunion
                // client du 10/09/2026) — le commercial qui ne connaît pas la
                // référence ou le client ouvre la liste et choisit.
                IconButton(
                  tooltip: 'Ouvrir la liste',
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.enabled ? _toggleBrowse : null,
                  icon: Icon(
                    _open && _browsing
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    size: 26.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open) _panel(),
      ],
    );
  }

  Widget _panel() {
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      constraints: BoxConstraints(maxHeight: 260.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: _results.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Text(
                _loading
                    ? 'Recherche…'
                    : _enEchec
                        ? 'Recherche indisponible — vérifiez votre connexion'
                        : (_searched ? _emptyLabel : 'Saisissez au moins 2 caractères'),
                style: TextStyle(
                    fontSize: 13.sp,
                    color: _enEchec ? AppColors.error : AppColors.textMuted),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: _results.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) {
                final r = _results[i];
                return InkWell(
                  onTap: () => _select(r),
                  child: Container(
                    // 48 dp minimum tap target.
                    constraints: BoxConstraints(minHeight: 48.h),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          r.label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if ((r.code ?? '').isNotEmpty)
                          Text(
                            r.code!,
                            style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        );
  }
}

// ─── Cascade TAR des lignes d'échantillon (source 'teinte' / 'base') ─────────
//
// Réunion client du 10/09/2026 : teinte et base ne se tapent plus, elles se
// CHOISISSENT dans dbo.TAR. La référence de la MÊME ligne remplit la liste des
// teintes (SREF1) ; le couple référence + teinte celle des bases (SREF2). Tant
// que l'amont n'est pas choisi, le champ est inerte et dit pourquoi.
//
// La valeur vide d'une base est un CHOIX (« sans base ») : l'API la renvoie
// dans la liste quand elle existe et elle s'affiche comme une option à part
// entière. La valeur stockée reste une chaîne simple — les demandes saisies
// avant la cascade (teinte tapée librement) se rouvrent sans cas spécial.
//
// Le choix se fait dans une feuille de bas d'écran — l'idiome mobile — avec un
// filtre local quand la liste est longue (194 teintes sur certaines
// références). Les options sont rechargées à CHAQUE ouverture : l'API cache
// 5 minutes, l'appel est bon marché, et une liste d'une autre référence ne
// peut pas rester affichée.
class TarCascadeField extends ConsumerStatefulWidget {
  final String kind; // 'teinte' | 'base'
  final String label;

  /// Libellé du champ à renseigner AVANT celui-ci — « Référence » et « Teinte »
  /// sur un échantillon, « Produit réclamé » et « Sous-référence 1 » sur une
  /// réclamation. Un libellé figé mentirait sur l'un des deux.
  final String upstreamLabel;
  final String refValue;
  final String teinteValue;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const TarCascadeField({
    super.key,
    required this.kind,
    required this.label,
    required this.upstreamLabel,
    required this.refValue,
    required this.teinteValue,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  ConsumerState<TarCascadeField> createState() => _TarCascadeFieldState();
}

class _TarCascadeFieldState extends ConsumerState<TarCascadeField> {
  bool _loading = false;

  bool get _ready => widget.kind == 'teinte'
      ? widget.refValue.isNotEmpty
      : widget.refValue.isNotEmpty && widget.teinteValue.isNotEmpty;

  String get _placeholder =>
      !_ready ? "Choisir d'abord « ${widget.upstreamLabel} »" : '— Choisir —';

  Future<void> _openPicker() async {
    if (!widget.enabled || !_ready || _loading) return;
    setState(() => _loading = true);
    final lookup = ref.read(lookupServiceProvider);
    final res = widget.kind == 'teinte'
        ? await lookup.fetchTeintes(widget.refValue)
        : await lookup.fetchBases(widget.refValue, widget.teinteValue);
    if (!mounted) return;
    setState(() => _loading = false);

    final options = res.getOrElse(() => const <String>[]);
    if (res.isLeft()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('Chargement impossible — vérifiez votre connexion.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    if (options.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Aucune valeur pour « ${widget.upstreamLabel} » choisi.'),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }

    final picked = await showModalBottomSheet<(String,)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => _TarOptionsSheet(
        title: widget.label,
        options: options,
        current: widget.value,
      ),
    );
    // null = feuille refermée sans choix. La chaîne vide est un VRAI choix
    // (« sans sous-référence ») : l'enregistrement à un champ les distingue
    // sans recourir à une valeur sentinelle dans le texte lui-même.
    if (picked == null) return;
    widget.onChanged(picked.$1);
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.value.isNotEmpty ? widget.value : _placeholder;
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: widget.enabled && _ready ? _openPicker : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          enabled: widget.enabled && _ready,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          suffixIcon: _loading
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(Icons.arrow_drop_down_rounded,
                  size: 26.sp,
                  color: widget.enabled && _ready
                      ? AppColors.textMuted
                      : AppColors.border),
        ),
        child: Text(
          display,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: widget.value.isNotEmpty
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Contenu de la feuille de choix : filtre local (listes longues) + options.
class _TarOptionsSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String current;

  const _TarOptionsSheet({
    required this.title,
    required this.options,
    required this.current,
  });

  @override
  State<_TarOptionsSheet> createState() => _TarOptionsSheetState();
}

class _TarOptionsSheetState extends State<_TarOptionsSheet> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final q = _filter.trim().toLowerCase();
    final shown = q.isEmpty
        ? widget.options
        : widget.options.where((o) => o.toLowerCase().contains(q)).toList();

    return SafeArea(
      child: Padding(
        // Le clavier du filtre ne doit pas recouvrir la liste.
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.options.length > 8)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                  child: TextField(
                    autofocus: false,
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: InputDecoration(
                      hintText: 'Filtrer…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              Flexible(
                child: shown.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Text(
                          'Aucune option ne correspond au filtre',
                          style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: shown.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: AppColors.border),
                        itemBuilder: (_, i) {
                          final o = shown[i];
                          final selected =
                              o == widget.current && widget.current.isNotEmpty;
                          return InkWell(
                            onTap: () => Navigator.of(context).pop((o,)),
                            child: Container(
                              constraints: BoxConstraints(minHeight: 48.h),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: o.isEmpty
                                        ? Text(
                                            '(vide)',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.textMuted,
                                            ),
                                          )
                                        : Text(
                                            o,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: selected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                  ),
                                  if (selected)
                                    Icon(Icons.check_rounded,
                                        size: 18.sp, color: AppColors.primary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
