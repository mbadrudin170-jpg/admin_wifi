DropdownButtonFormField({
  super.key,
  required List<DropdownMenuItem<T>>? items,
  DropdownButtonBuilder? selectedItemBuilder,
  @Deprecated(
    'Use initialValue instead. '
    'This will set the initial value for the form field. '
    'This feature was deprecated after v3.33.0-1.0.pre.',
  )
  T? value,
  T? initialValue,
  Widget? hint,
  Widget? disabledHint,
  required this.onChanged,
  VoidCallback? onTap,
  int elevation = 8,
  TextStyle? style,
  Widget? icon,
  Color? iconDisabledColor,
  Color? iconEnabledColor,
  double iconSize = 24.0,
  bool isDense = true,
  bool isExpanded = false,
  double? itemHeight,
  Color? focusColor,
  FocusNode? focusNode,
  bool autofocus = false,
  Color? dropdownColor,
  InputDecoration? decoration,
  super.onSaved,
  super.validator,
  super.errorBuilder,
  super.forceErrorText,
  AutovalidateMode? autovalidateMode,
  double? menuMaxHeight,
  bool? enableFeedback,
  AlignmentGeometry alignment = AlignmentDirectional.centerStart,
  BorderRadius? borderRadius,
  EdgeInsetsGeometry? padding,
  this.barrierDismissible = true,
  this.mouseCursor,
  this.dropdownMenuItemMouseCursor,
  // When adding new arguments, consider adding similar arguments to
  // DropdownButton.
}) : assert(
       items == null ||
           items.isEmpty ||
           (initialValue == null && value == null) ||
           items
                   .where((DropdownMenuItem<T> item) => item.value == (initialValue ?? value))
                   .length ==
               1,
       "There should be exactly one item with [DropdownButton]'s value: "
       '${initialValue ?? value}. \n'
       'Either zero or 2 or more [DropdownMenuItem]s were detected '
       'with the same value',
     ),
     assert(itemHeight == null || itemHeight >= kMinInteractiveDimension),
     decoration = decoration ?? const InputDecoration(),
     super(
       initialValue: initialValue ?? value,
       autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
       builder: (FormFieldState<T> field) {
         final state = field as _DropdownButtonFormFieldState<T>;
         InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
             .applyDefaults(InputDecorationTheme.of(field.context));

         final bool showSelectedItem =
             items != null &&
             items.where((DropdownMenuItem<T> item) => item.value == state.value).isNotEmpty;
         final bool isDropdownEnabled = onChanged != null && items != null && items.isNotEmpty;
         // If decoration hintText is provided, use it as the default value for both hint and disabledHint.
         final Widget? decorationHint = effectiveDecoration.hintText != null
             ? Text(effectiveDecoration.hintText!)
             : null;
         final Widget? effectiveHint = hint ?? decorationHint;
         final Widget? effectiveDisabledHint = disabledHint ?? effectiveHint;
         final bool isHintOrDisabledHintAvailable = isDropdownEnabled
             ? effectiveHint != null
             : effectiveHint != null || effectiveDisabledHint != null;
         final bool isEmpty = !showSelectedItem && !isHintOrDisabledHintAvailable;

         if (field.errorText != null || effectiveDecoration.hintText != null) {
           final Widget? error = field.errorText != null && errorBuilder != null
               ? errorBuilder(state.context, field.errorText!)
               : null;
           final String? errorText = error == null ? field.errorText : null;
           // Clear the decoration hintText because DropdownButton has its own hint logic.
           final String? hintText = effectiveDecoration.hintText != null ? '' : null;

           effectiveDecoration = effectiveDecoration.copyWith(
             error: error,
             errorText: errorText,
             hintText: hintText,
           );
         }

         // An unfocusable Focus widget so that this widget can detect if its
         // descendants have focus or not.
         return Focus(
           canRequestFocus: false,
           skipTraversal: true,
           child: DropdownButtonHideUnderline(
             child: DropdownButton<T>._formField(
               items: items,
               selectedItemBuilder: selectedItemBuilder,
               value: state.value,
               hint: effectiveHint,
               disabledHint: effectiveDisabledHint,
               onChanged: onChanged == null ? null : state.didChange,
               onTap: onTap,
               elevation: elevation,
               style: style,
               icon: icon,
               iconDisabledColor: iconDisabledColor,
               iconEnabledColor: iconEnabledColor,
               iconSize: iconSize,
               isDense: isDense,
               isExpanded: isExpanded,
               itemHeight: itemHeight,
               focusColor: focusColor,
               focusNode: focusNode,
               autofocus: autofocus,
               dropdownColor: dropdownColor,
               menuMaxHeight: menuMaxHeight,
               enableFeedback: enableFeedback,
               alignment: alignment,
               borderRadius: borderRadius,
               inputDecoration: effectiveDecoration,
               isEmpty: isEmpty,
               padding: padding,
               barrierDismissible: barrierDismissible,
               mouseCursor: mouseCursor,
               dropdownMenuItemMouseCursor: dropdownMenuItemMouseCursor,
             ),
           ),
         );
       },
     );