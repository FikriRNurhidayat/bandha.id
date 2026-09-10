import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/services/platform_keyboard.dart';
import 'package:bandha/core/presentation/services/platform_keyboard_binding.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_editor_view_model.dart';
import 'package:flutter/material.dart';

typedef ControllableEntryEditorFormBuilder<C extends Controllable> =
    List<Widget> Function(
      BuildContext context,
      ControllableEntryEditorViewState<C> state,
    );

class ControllableEntryEditorView<C extends Controllable>
    extends StatefulWidget {
  const ControllableEntryEditorView({
    super.key,
    required this.controllerId,
    required this.formBuilder,
    required this.vmResolver,
    this.entryId,
    this.readOnly = false,
    this.editable = false,
    this.destroyable = false,
  });

  final String controllerId;
  final String? entryId;
  final bool readOnly;
  final bool editable;
  final bool destroyable;
  final ControllableEntryEditorViewModel<C> Function() vmResolver;
  final ControllableEntryEditorFormBuilder<C> formBuilder;

  factory ControllableEntryEditorView.builder(
    BuildContext context, {
    required String controllerId,
    bool? readOnly,
    String? entryId,
    required List<Widget> Function(
      BuildContext context,
      ControllableEntryEditorViewState<C> state,
    )
    formBuilder,
  }) {
    return ControllableEntryEditorView<C>(
      controllerId: controllerId,
      entryId: entryId,
      formBuilder: formBuilder,
      readOnly: readOnly ?? false,
      vmResolver: () => DependencyInjector.of(
        context,
      ).get<ControllableEntryEditorViewModel<C>>(),
    );
  }

  @override
  State<ControllableEntryEditorView<C>> createState() =>
      ControllableEntryEditorViewState<C>();
}

class ControllableEntryEditorViewState<C extends Controllable>
    extends State<ControllableEntryEditorView<C>> {
  late final vm = widget.vmResolver();

  Map<String, dynamic> get formData => vm.formData;
  C get controller => vm.controller.requireData;
  Entry? get entry => vm.entry.data;

  @override
  initState() {
    PlatformKeyboardBinding.instance.attach();
    vm
        .readOnly(widget.readOnly)
        .withController(widget.controllerId)
        .withEntry(widget.entryId)
        .initialize();
    super.initState();
  }

  Future<void> submit() async {
    final form = vm.formKey.currentState!;
    if (!form.validate()) {
      return;
    }

    form.save();

    try {
      final draft = await vm.save();
      if (!mounted) return;
      Navigator.of(context).pop<Draft<Entry>>(draft);
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    }
  }

  @override
  dispose() {
    vm.dispose();
    PlatformKeyboardBinding.instance.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlatformKeyboard(
      notifier: PlatformKeyboardBinding.instance.notifier,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.readOnly ? "$C entry details" : "Enter $C entry details",
            style: theme.textTheme.titleMedium,
          ),
          automaticallyImplyLeading: false,
          actions: [
            if (!widget.readOnly)
              IconButton(onPressed: submit, icon: Icon(Icons.check)),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, child) {
                final theme = Theme.of(context);
                switch (vm.controller.connectionState) {
                  case ConnectionState.done when vm.controller.hasData:
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: vm.formKey,
                        child: Column(
                          spacing: 16,
                          children: widget.formBuilder(context, this),
                        ),
                      ),
                    );
                  case ConnectionState.done when vm.controller.hasError:
                    return ListView(
                      children: [
                        ListTile(
                          dense: true,
                          title: Text(
                            vm.controller.error.runtimeType.toString(),
                            style: theme.textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            vm.controller.stackTrace?.toString() ??
                                "Stack trace is not available.",
                          ),
                        ),
                      ],
                    );
                  case ConnectionState.waiting:
                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
