import 'package:bandha/core/presentation/controllers/date_time_controller.dart';
import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/widgets/fields/date_time_field.dart';
import 'package:bandha/core/presentation/widgets/fields/select_field.dart';
import 'package:bandha/core/types/timestamp.dart';
import 'package:flutter/material.dart';

class TimestampField extends StatefulWidget {
  const TimestampField({
    super.key,
    this.selectController,
    this.dateTimeController,
    this.decoration = const InputDecoration(),
    this.dateTimeDecoration = const InputDecoration(),
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
  });

  final TextInputAction? textInputAction;
  final InputDecoration decoration;
  final InputDecoration dateTimeDecoration;
  final ValueChanged<Timestamp>? onChanged;
  final ValueChanged<Timestamp>? onSubmitted;
  final bool readOnly;
  final SelectController<TimestampOption>? selectController;
  final DateTimeController? dateTimeController;

  @override
  State<TimestampField> createState() => _TimestampFieldState();
}

class _TimestampFieldState extends State<TimestampField> {
  DateTimeController? dateTimeController;
  SelectController<TimestampOption>? selectController;

  late final effectiveSelectController =
      widget.selectController ??
      (selectController ??= SelectController<TimestampOption>(
        selectOptions: TimestampOption.values.map(
          (option) => SelectOption(text: option.toString(), value: option),
        ),
        availableValues: TimestampOption.values,
      ));

  late final effectiveDateTimeController =
      widget.dateTimeController ??
      (dateTimeController ??= DateTimeController(null));

  @override
  dispose() {
    selectController?.dispose();
    dateTimeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: ListenableBuilder(
        listenable: effectiveSelectController,
        builder: (context, child) => Column(
          spacing: 16,
          children: [
            if (!widget.readOnly)
              FocusTraversalOrder(
                order: NumericFocusOrder(1),
                child: SelectField<TimestampOption>(
                  readOnly: widget.readOnly,
                  controller: effectiveSelectController,
                  decoration: widget.decoration,
                  onChanged: _handleTimestampOptionChange,
                  options: effectiveSelectController.selectOptions,
                  textInputAction:
                      effectiveSelectController.value.contains(
                        TimestampOption.specific,
                      )
                      ? TextInputAction.next
                      : widget.textInputAction,
                  onSubmitted: (v) {
                    if (!effectiveSelectController.value.contains(
                          TimestampOption.specific,
                        ) ||
                        v.isEmpty) {
                      return;
                    }
                    widget.onSubmitted?.call(Timestamp(v.first));
                  },
                ),
              ),
            if (effectiveSelectController.value.contains(
              TimestampOption.specific,
            ))
              FocusTraversalOrder(
                order: NumericFocusOrder(2),
                child: DateTimeField(
                  controller: effectiveDateTimeController,
                  readOnly: widget.readOnly,
                  decoration: widget.dateTimeDecoration,
                  textInputAction:
                      widget.textInputAction ?? TextInputAction.next,
                  onChanged: _handleDateTimeChange,
                  onSubmitted: (v) {
                    if (v == null) return;
                    widget.onSubmitted?.call(
                      Timestamp(TimestampOption.specific, v),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTimestampOptionChange(Iterable<TimestampOption> v) {
    final option = v.firstOrNull;
    if (option == null) return;
    if (option == TimestampOption.specific) return;
    widget.onChanged?.call(Timestamp(option));
  }

  void _handleDateTimeChange(DateTime? v) {
    if (v == null) return;
    widget.onChanged?.call(Timestamp(TimestampOption.specific, v));
  }
}
