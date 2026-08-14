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
  TextEditingController _ctrl(String name) => _controllers.putIfAbsent(name, () {
        final c = TextEditingController(text: widget.values[name]?.toString() ?? '');
        c.addListener(() => _set(name, c.text));
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
          _set(f.name, current);
        });
        return c;
      });

  List<Map<String, dynamic>> _rows(String name) => widget.values[name] is List
      ? List<Map<String, dynamic>>.from(
          (widget.values[name] as List).map((e) => Map<String, dynamic>.from(e as Map)))
      : <Map<String, dynamic>>[];

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

  static const _searchableSources = {'client', 'article'};

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
    // A searchable data source wins over the raw type: still a text input, but
    // backed by an ERP suggestion list. Anything the schema does not mark keeps
    // its old widget.
    if (_searchableSources.contains(f.source) && f.type != 'reflist') {
      return _labelled(
        f,
        ErpAutocompleteField(
          controller: _ctrl(f.name),
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
            controller: _ctrl(f.name),
            hint: f.label,
            maxLines: 4,
            required: f.required,
          ),
        );
      case 'number':
        return _labelled(
          f,
          AppTextField(
            controller: _ctrl(f.name),
            hint: f.label,
            keyboardType: TextInputType.number,
            required: f.required,
          ),
        );
      case 'date':
        return _labelled(
          f,
          AppDateField(
            controller: _ctrl(f.name),
            hint: f.label,
            required: f.required,
            onTap: () => pickDate(context, _ctrl(f.name)),
          ),
        );
      case 'time':
        return _labelled(
          f,
          AppDateField(
            controller: _ctrl(f.name),
            hint: f.label,
            prefixIcon: Icons.schedule_outlined,
            required: f.required,
            onTap: () => pickTime(context, _ctrl(f.name)),
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
            controller: _ctrl(f.name),
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
                    child: _searchableSources.contains(sf.source)
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
    _lastQuery = row.label.trim();
    widget.controller.value = TextEditingValue(
      text: row.label,
      selection: TextSelection.collapsed(offset: row.label.length),
    );
    FocusScope.of(context).unfocus();
    setState(() {
      _open = false;
      _loading = false;
      _results = const [];
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
            // unfocused field steals taps from the fields below it.
            if (!has && _open) setState(() => _open = false);
          },
          child: AppTextField(
            controller: widget.controller,
            hint: widget.hint,
            required: widget.required,
            readOnly: !widget.enabled,
            // Client et produit se saisissent en capitales, comme les données ERP.
            inputFormatters: const [UpperCaseTextFormatter()],
            suffix: _loading
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
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
