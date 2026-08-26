import 'package:bandha/core/presentation/controllers/select_controller.dart';
import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/services/platform_keyboard_binding.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/fields/date_time_field.dart';
import 'package:bandha/core/presentation/widgets/fields/number_field.dart';
import 'package:bandha/core/presentation/widgets/fields/select_field.dart';
import 'package:bandha/core/presentation/widgets/fields/timestamp_field.dart';
import 'package:flutter/material.dart';

class ToolEditorPreview extends StatefulWidget {
  const ToolEditorPreview({super.key});

  @override
  State<ToolEditorPreview> createState() => _ToolEditorPreviewState();
}

class _ToolEditorPreviewState extends State<ToolEditorPreview> {
  late final textEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    PlatformKeyboardBinding.instance.attach();
  }

  @override
  dispose() {
    PlatformKeyboardBinding.instance.detach();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlatformKeyboard(
      notifier: PlatformKeyboardBinding.instance.notifier,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Editor Panel", style: theme.textTheme.titleMedium),
          automaticallyImplyLeading: false,
          actions: [],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: XInputStyles.field(
                      labelText: "Text 1",
                      hintText: "Enter text 1...",
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  TextField(
                    autofocus: false,
                    decoration: XInputStyles.field(
                      labelText: "Text 2",
                      hintText: "Enter text 2...",
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  NumberField(
                    autofocus: true,
                    decoration: XInputStyles.field(
                      labelText: "Number 2",
                      hintText: "Enter number 2...",
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  DateTimeField(
                    decoration: XInputStyles.field(
                      labelText: "Date 1",
                      hintText: "Enter date 1...",
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  SelectField<String>(
                    decoration: XInputStyles.field(
                      labelText: "Select 1",
                      hintText: "Enter select 1...",
                    ),
                    textInputAction: TextInputAction.next,
                    actions: [
                      ActionChip(
                        label: Text("Add new item"),
                        avatar: Icon(Icons.add_outlined),
                      ),
                    ],
                    options: [
                      SelectOption(text: "Adipisci", value: "Adipisci"),
                      SelectOption(text: "Amet", value: "Amet"),
                      SelectOption(text: "Consectetur", value: "Consectetur"),
                      SelectOption(text: "Dolor", value: "Dolor"),
                      SelectOption(text: "Dolorem", value: "Dolorem"),
                      SelectOption(text: "Est", value: "Est"),
                      SelectOption(text: "Ipsum", value: "Ipsum"),
                      SelectOption(text: "Neque", value: "Neque"),
                      SelectOption(text: "Porro", value: "Porro"),
                      SelectOption(text: "Qui", value: "Qui"),
                      SelectOption(text: "Quia", value: "Quia"),
                      SelectOption(text: "Quisquam", value: "Quisquam"),
                      SelectOption(text: "Sit", value: "Sit"),
                      SelectOption(text: "Velit", value: "Velit"),
                    ],
                  ),
                  NumberField(
                    autofocus: true,
                    decoration: XInputStyles.field(
                      labelText: "Number 2",
                      hintText: "Enter number 2...",
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  SelectField<String>(
                    multiple: true,
                    decoration: XInputStyles.field(
                      labelText: "Select 2",
                      hintText: "Enter select 2...",
                    ),
                    textInputAction: TextInputAction.next,
                    actions: [
                      ActionChip(
                        label: Text("Add new item"),
                        avatar: Icon(Icons.add_outlined),
                      ),
                    ],
                    options: [
                      SelectOption(text: "Adipisci", value: "Adipisci"),
                      SelectOption(text: "Amet", value: "Amet"),
                      SelectOption(text: "Consectetur", value: "Consectetur"),
                      SelectOption(text: "Dolor", value: "Dolor"),
                      SelectOption(text: "Dolorem", value: "Dolorem"),
                      SelectOption(text: "Est", value: "Est"),
                      SelectOption(text: "Ipsum", value: "Ipsum"),
                      SelectOption(text: "Neque", value: "Neque"),
                      SelectOption(text: "Porro", value: "Porro"),
                      SelectOption(text: "Qui", value: "Qui"),
                      SelectOption(text: "Quia", value: "Quia"),
                      SelectOption(text: "Quisquam", value: "Quisquam"),
                      SelectOption(text: "Sit", value: "Sit"),
                      SelectOption(text: "Velit", value: "Velit"),
                    ],
                  ),
                  TimestampField(
                    decoration: XInputStyles.field(
                      labelText: "Timestamp 1",
                      hintText: "Select timestamp 1...",
                    ),
                    dateTimeDecoration: XInputStyles.field(
                      labelText: "Date 1",
                      hintText: "Select date 1...",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
