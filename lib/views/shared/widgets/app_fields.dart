import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../core/theme/app_colors.dart';

/// Shared field style matching the login screen design.
/// All forms should use these instead of raw TextFormField.

// ─── Text Field ──────────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool digitsOnly;
  final bool phoneWithCountry;
  final String countryCode;
  final ValueChanged<String?>? onCountryCodeChanged;
  final List<String> countryCodes;
  final String? requiredMessage;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffix,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.accentColor,
    this.digitsOnly = false,
    this.phoneWithCountry = false,
    this.countryCode = '+212',
    this.onCountryCodeChanged,
    this.countryCodes = const ['+212', '+33', '+216', '+213', '+1', '+44', '+49'],
    this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    final isNumericKeyboard = keyboardType == TextInputType.number || keyboardType == TextInputType.phone;
    final enforceDigits = digitsOnly || isNumericKeyboard || phoneWithCountry;
    final formatters = <TextInputFormatter>[
      if (enforceDigits) FilteringTextInputFormatter.digitsOnly,
      ...?inputFormatters,
    ];

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: maxLines > 1
          ? TextInputType.multiline
          : (phoneWithCountry ? TextInputType.phone : keyboardType),
      inputFormatters: formatters,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: phoneWithCountry
            ? Container(
                margin: EdgeInsets.only(left: 8.w),
                child: CountryCodePicker(
                  onChanged: (code) => onCountryCodeChanged?.call(code.dialCode),
                  initialSelection: countryCode,
                  favorite: countryCodes,
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  textStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: EdgeInsets.zero,
                ),
              )
            : (prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20.sp)
                : null),
        suffixIcon: suffix,
        alignLabelWithHint: maxLines > 1,
        errorMaxLines: 2,
        errorStyle: TextStyle(
          fontSize: 11.sp,
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: color, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator ??
          (required
              ? (v) {
                  if (v == null || v.trim().isEmpty) {
                    if (requiredMessage != null) return requiredMessage;
                    if (enforceDigits) return 'Veuillez saisir ${hint.toLowerCase()}';
                    return 'Veuillez renseigner ${hint.toLowerCase()}';
                  }
                  return null;
                }
              : null),
    );
  }
}

// ─── Date Field ──────────────────────────────────────────────────────────────

class AppDateField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool required;
  final Color? accentColor;
  final Future<void> Function() onTap;
  final String? Function(String?)? validator;
  final String? requiredMessage;

  const AppDateField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onTap,
    this.prefixIcon,
    this.required = false,
    this.accentColor,
    this.validator,
    this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          prefixIcon ?? Icons.calendar_today_outlined,
          color: controller.text.isEmpty ? AppColors.textSecondary : color,
          size: 20.sp,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : GestureDetector(
                onTap: () => controller.clear(),
                child: Icon(Icons.close, color: AppColors.textSecondary, size: 18.sp),
              ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: color, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorMaxLines: 2,
        errorStyle: TextStyle(
          fontSize: 11.sp,
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? (requiredMessage ?? 'Veuillez sélectionner ${hint.toLowerCase()}')
                    : null
              : null),
    );
  }
}

// ─── Dropdown Field ──────────────────────────────────────────────────────────

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final Color? accentColor;
  final String? Function(T?)? validator;
  final bool required;
  final String? requiredMessage;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.accentColor,
    this.validator,
    this.required = true,
    this.requiredMessage,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return FormField<T>(
      initialValue: value,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator ??
          (required
              ? (v) => v == null
                    ? (requiredMessage ??
                        'Veuillez sélectionner ${hint.toLowerCase()}')
                    : null
              : null),
      builder: (state) {
        final selected = items.where((item) => item.value == state.value).toList();
        final selectedItem = selected.isNotEmpty ? selected.first : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () async {
                final picked = await _showPickerSheet(context, state.value, color);
                if (picked != null) {
                  state.didChange(picked);
                  onChanged(picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20.sp)
                      : null,
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 22.sp),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide(
                      color: state.hasError ? AppColors.error : Colors.transparent,
                      width: state.hasError ? 1.2 : 0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide(
                      color: state.hasError ? AppColors.error : Colors.transparent,
                      width: state.hasError ? 1.2 : 0,
                    ),
                  ),
                ),
                child: selectedItem == null
                    ? Text(
                        hint,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      )
                    : DefaultTextStyle(
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        child: selectedItem.child,
                      ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: state.hasError
                  ? Padding(
                      padding: EdgeInsets.only(left: 12.w, top: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 14.sp, color: AppColors.error),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              state.errorText ?? 'Veuillez sélectionner une option',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Future<T?> _showPickerSheet(BuildContext context, T? selectedValue, Color color) {
    return showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
              child: Row(
                children: [
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.value == selectedValue;
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(item.value),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    title: DefaultTextStyle(
                      style: TextStyle(
                        color: isSelected ? color : AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      child: item.child,
                    ),
                    trailing: isSelected ? Icon(Icons.check_rounded, color: color, size: 18.r) : null,
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        );
      },
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class AppFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const AppFormSection({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 14.r, color: c),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: c,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Date Picker Helper ───────────────────────────────────────────────────────

Future<void> pickDate(
  BuildContext context,
  TextEditingController controller, {
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: firstDate ?? DateTime(2020),
    lastDate: lastDate ?? DateTime(2030),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        ),
      ),
      child: child!,
    ),
  );
  if (date != null && context.mounted) {
    controller.text =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class FormStepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final List<String> titles;
  final List<IconData> icons;
  final Color color;
  final void Function(int) onTap;

  const FormStepIndicator({
    super.key,
    required this.current,
    required this.total,
    required this.titles,
    required this.icons,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      child: Row(
        children: List.generate(total, (index) {
          final isDone = index < current;
          final isActive = index == current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isDone ? () => onTap(index) : null,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: isDone
                                ? color
                                : isActive
                                    ? color.withValues(alpha: 0.1)
                                    : const Color(0xFFF4F7FC),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone || isActive ? color : AppColors.border,
                              width: isDone || isActive ? 2 : 1.5,
                            ),
                            boxShadow: isActive
                                ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? Icon(Icons.check_rounded, size: 18.r, color: Colors.white)
                                : Icon(icons[index], size: 17.r, color: isActive ? color : AppColors.textSecondary),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          titles[index],
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? color : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      margin: EdgeInsets.only(bottom: 26.h),
                      decoration: BoxDecoration(
                        color: index < current ? color : AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Form Bottom Nav ──────────────────────────────────────────────────────────

class FormBottomNav extends StatelessWidget {
  final bool isLoading;
  final bool isLast;
  final bool isFirst;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final Color color;

  const FormBottomNav({
    super.key,
    required this.isLoading,
    required this.isLast,
    required this.isFirst,
    required this.onBack,
    required this.onNext,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6), width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Container(
              height: 52.h,
              decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(16.r)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: isLoading ? null : onBack,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded, size: 14.r, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text(isFirst ? 'Annuler' : 'Retour', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: isLoading ? null : onNext,
                    child: Center(
                      child: isLoading && isLast
                          ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isLast ? 'Soumettre' : 'Continuer', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                                SizedBox(width: 8.w),
                                Icon(isLast ? Icons.send_rounded : Icons.arrow_forward_ios_rounded, size: 15.r, color: Colors.white),
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
