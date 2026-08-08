import 'package:bandha/core/presentation/layouts/app_editor_layout.dart';
import 'package:bandha/core/presentation/types/pager.dart';
import 'package:bandha/core/presentation/widgets/app_amount_form_field.dart';
import 'package:bandha/core/presentation/widgets/app_text_form_field.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:bandha/modules/journals/presentation/models/journal_display.dart';
import 'package:bandha/modules/journals/presentation/view_models/journal_editor_view_model.dart';
import 'package:flutter/material.dart';

class JournalEditorView extends StatefulWidget {
  final String? id;
  final bool readOnly;

  const JournalEditorView({super.key, this.id, this.readOnly = false});

  @override
  State<JournalEditorView> createState() => _JournalEditorViewState();
}

class _JournalEditorViewState extends State<JournalEditorView> {
  JournalEditorViewModel? vm;
  final formKey = GlobalKey<FormState>();

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (vm == null) {
      vm = JournalEditorViewModel.of(context);
      vm?.init(id: widget.id, readOnly: widget.readOnly);
      vm?.assetProvider.init();
    }
  }

  @override
  dispose() {
    super.dispose();
    vm?.dispose();
  }

  Future<void> handleSubmit() async {
    final form = formKey.currentState!;
    if (!form.validate()) return;

    form.save();
    await vm?.save();

    if (vm?.hasError != null && vm!.hasError) return;
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AppEditorLayout<JournalDisplay>(
      title: widget.readOnly ? "Journal details" : "Enter journal details",
      valueListenable: vm!.notifier,
      onSubmit: handleSubmit,
      readOnly: widget.readOnly,
      builder: (BuildContext context) {
        return Form(
          key: formKey,
          child: FocusScope(
            child: Column(
              spacing: 16,
              children: [
                AppTextFormField(
                  autofocus: !widget.readOnly,
                  textInputAction: TextInputAction.next,
                  initialValue: vm?.name,
                  labelText: "Name",
                  hintText: "Enter journal name...",
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (value) => vm?.nameNotifier.value = value ?? '',
                ),
                AppTextFormField(
                  initialValue: vm?.holderName,
                  textInputAction: TextInputAction.next,
                  labelText: "Holder name",
                  hintText: "Enter journal holder name...",
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => vm?.holderNameNotifier.value = v ?? '',
                ),
                AppAmountFormField(
                  initialValue: vm?.balance,
                  textInputAction: TextInputAction.next,
                  labelText: 'Balance',
                  hintText: 'Enter journal balance...',
                  validator: (v) => v == null ? 'Required' : null,
                  onSaved: (v) => vm?.balanceNotifier.value = v ?? 0,
                  onFieldSubmitted: (v) async {
                    await handleSubmit();
                  },
                ),
                ValueListenableBuilder<AsyncSnapshot<Pager<AssetDisplay>>>(
                  valueListenable: vm!.assetProvider.notifier,
                  builder: (context, snapshot, child) {
                    return SizedBox();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
