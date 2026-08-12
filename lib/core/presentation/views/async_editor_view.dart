import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/layouts/x_editor_layout.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:flutter/material.dart';

typedef AsyncEditorFormBuilder<E extends Entity> =
    List<Widget> Function(BuildContext context, AsyncEditorViewState<E> state);

class AsyncEditorView<E extends Entity> extends StatefulWidget {
  final String? id;
  final String name;
  final bool readOnly;
  final AsyncEditorViewModel<E> Function() vmResolver;
  final AsyncEditorFormBuilder<E> formBuilder;

  const AsyncEditorView({
    super.key,
    this.id,
    required this.name,
    required this.readOnly,
    required this.vmResolver,
    required this.formBuilder,
  });

  factory AsyncEditorView.builder(
    BuildContext context, {
    String? id,
    required String name,
    bool readOnly = false,
    required AsyncEditorFormBuilder<E> formBuilder,
  }) {
    return AsyncEditorView(
      id: id,
      name: name,
      readOnly: readOnly,
      formBuilder: formBuilder,
      vmResolver: () =>
          DependencyInjector.of(context).get<AsyncEditorViewModel<E>>(),
    );
  }

  @override
  State<AsyncEditorView<E>> createState() => AsyncEditorViewState<E>();
}

class AsyncEditorViewState<E extends Entity> extends State<AsyncEditorView<E>> {
  late final AsyncEditorViewModel<E> vm = widget.vmResolver();

  Map<String, dynamic> get formData => vm.formData;

  @override
  initState() {
    super.initState();

    vm.init(id: widget.id, readOnly: widget.readOnly);
  }

  Future<void> submit() async {
    final form = vm.formKey.currentState!;
    if (!form.validate()) {
      return;
    }

    form.save();
    await vm.save();

    if (vm.hasError) {
      debugPrint("hasError: ${vm.hasError}");
      debugPrint("error: ${vm.error}");
      debugPrint("stackTrace: ${vm.stackTrace}");
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop<Draft<E>>(vm.requireData);
  }

  @override
  Widget build(BuildContext context) {
    return XEditorLayout(
      name: widget.readOnly
          ? "${widget.name} details"
          : "Enter ${widget.name.toLowerCase()} details",
      readOnly: widget.readOnly,
      onSubmit: submit,
      builder: (BuildContext context) {
        return Form(
          key: vm.formKey,
          child: FocusScope(
            child: Column(
              spacing: 16,
              children: widget.formBuilder(context, this),
            ),
          ),
        );
      },
      notifier: vm.notifier,
    );
  }
}
