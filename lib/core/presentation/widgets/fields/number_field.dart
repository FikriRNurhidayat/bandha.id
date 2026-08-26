import 'package:bandha/core/presentation/formatters/numeric_formatter.dart';
import 'package:flutter/material.dart';

class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.controller,
    this.onChanged,
    this.numericFormatter,
    this.onSubmitted,
  });

  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final TextEditingController? controller;
  final NumericFormatter? numericFormatter;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final ValueChanged<double?>? onChanged;
  final ValueChanged<double?>? onSubmitted;

  @override
  State<NumberField> createState() => NumberFieldState();
}

class NumberFieldState extends State<NumberField> {
  TextEditingController? controller;
  NumericFormatter? numericFormatter;
  FocusNode? focusNode;

  late final effectiveFocusNode =
      widget.focusNode ??
      (focusNode ??= FocusNode(debugLabel: widget.decoration.labelText));
  late final effectiveNumericFormatter =
      widget.numericFormatter ??
      (numericFormatter ??= NumericFormatter(
        allowFraction: true,
        fractionDigits: 2,
        thousandSeparator: ',',
      ));
  late final effectiveController =
      widget.controller ?? (controller ??= TextEditingController());

  @override
  dispose() {
    focusNode?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onSubmitted: (valueText) {
        final value = double.tryParse(valueText);
        widget.onSubmitted?.call(value);
      },
      focusNode: effectiveFocusNode,
      controller: effectiveController,
      inputFormatters: [effectiveNumericFormatter],
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      decoration: widget.decoration,
      onChanged: (val) {
        double? number = double.tryParse(val.replaceAll(',', ''))?.abs();
        widget.onChanged?.call(number);
      },
    );
  }
}
