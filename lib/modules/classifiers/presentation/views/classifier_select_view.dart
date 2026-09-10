import 'dart:async';

import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/presentation/view_models/classifier_select_view_model.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:flutter/material.dart';

class ClassifierSelectView<T extends Classifier<T>> extends StatefulWidget {
  const ClassifierSelectView({
    super.key,
    required this.vmResolver,
    this.initialValue = const [],
    this.multiple = false,
  });

  final ClassifierSelectViewModel<T> Function() vmResolver;
  final bool multiple;
  final Iterable<T> initialValue;

  factory ClassifierSelectView.builder(
    BuildContext context, {
    Iterable<T> initialValue = const [],
    bool multiple = false,
  }) {
    return ClassifierSelectView<T>(
      initialValue: initialValue,
      multiple: multiple,
      vmResolver: () =>
          DependencyInjector.of(context).get<ClassifierSelectViewModel<T>>(),
    );
  }

  @override
  State<ClassifierSelectView<T>> createState() =>
      _ClassifierSelectViewState<T>();
}

class _ClassifierSelectViewState<T extends Classifier<T>>
    extends State<ClassifierSelectView<T>> {
  late final vm = widget.vmResolver();
  final controller = TextEditingController();
  final focusNode = FocusNode();
  Timer? debounceTimer;

  @override
  initState() {
    vm.setFilter({"readonly_eq": false});
    vm.query().then((_) {
      if (widget.initialValue.isNotEmpty) {
        vm.selectAll(widget.initialValue.map((i) => Item<T>(i)));
      }
    });
    super.initState();
  }

  @override
  dispose() {
    vm.dispose();
    controller.dispose();
    focusNode.dispose();
    debounceTimer?.cancel();
    super.dispose();
  }

  void handleSubmit() async {
    if (!vm.hasData || vm.requireData.isEmpty) {
      final name = controller.text.trim();
      await vm.create(name);
      await vm.select(
        vm.candidates.firstWhere((candidate) => candidate.entity.name == name),
      );
      controller.value = TextEditingValue.empty;
      handleTextChange(controller.text);
      focusNode.requestFocus();
      return;
    }

    if (!mounted) return;

    if (vm.hasData && vm.requireData.isNotEmpty && vm.requireData.length == 1) {
      return Navigator.of(context).pop([vm.requireData.first]);
    }

    if (vm.candidates.isNotEmpty) {
      return Navigator.of(context).pop(vm.candidates);
    }
  }

  void handleTextChange(String query) {
    if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 100), () async {
      if (query.isNotEmpty && vm.hasData && vm.requireData.isNotEmpty) {
        vm.setFilter({"name_like": query, "readonly_eq": false});
        await vm.query();
      }

      if (query.isEmpty) {
        vm.setFilter({"readonly_eq": false});
        await vm.query();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: vm.notifier,
      builder: (context, snapshot, child) {
        Widget body;

        if (snapshot.connectionState == ConnectionState.waiting) {
          body = SizedBox.shrink();
        } else if (snapshot.hasError) {
          body = ListView(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  snapshot.error.runtimeType.toString(),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  snapshot.stackTrace?.toString() ??
                      "Stack trace is not available.",
                ),
              ),
            ],
          );
        } else {
          final listView = ListView.builder(
            shrinkWrap: true,
            itemCount: vm.pager.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.category_outlined),
                  title: TextField(
                    autofocus: true,
                    focusNode: focusNode,
                    controller: controller,
                    onChanged: handleTextChange,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Enter ${T.toString().toLowerCase()}...',
                    ),
                    onSubmitted: (text) async {
                      handleSubmit();
                    },
                  ),
                  trailing:
                      (snapshot.hasData && snapshot.requireData.isNotEmpty)
                      ? IconButton(
                          icon: Icon(Icons.search_outlined),
                          onPressed: () async {},
                        )
                      : IconButton(
                          icon: Icon(Icons.check_outlined),
                          onPressed: () async {
                            await vm.create(controller.text);
                            controller.value = TextEditingValue.empty;
                            handleTextChange(controller.text);
                          },
                        ),
                  onTap: () {},
                );
              }

              final item = vm.pager[index - 1];

              if (widget.multiple) {
                return CheckboxListTile(
                  dense: true,
                  secondary: Icon(
                    item.isSelected ? Icons.label : Icons.label_outlined,
                  ),
                  title: Text(item.entity.name),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (bool? value) async {
                    if (value == null) return;
                    if (value) {
                      await vm.select(item);
                    } else {
                      await vm.deselect(item);
                    }
                  },
                  value: item.isSelected,
                );
              }

              return RadioListTile(
                dense: true,
                title: Text(item.entity.name),
                secondary: Icon(
                  item.isSelected ? Icons.label : Icons.label_outlined,
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                value: item,
              );
            },
          );

          if (widget.multiple) {
            body = listView;
          } else {
            body = ValueListenableBuilder(
              valueListenable: vm.candidatesNotifier,
              builder: (context, value, child) {
                return RadioGroup<Item<T>>(
                  groupValue: vm.candidates.firstOrNull,
                  onChanged: (Item<T>? item) async {
                    if (item == null) return;
                    await vm.selectExclusively(item);
                  },
                  child: listView,
                );
              },
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(T.toString(), style: theme.textTheme.titleMedium),
            automaticallyImplyLeading: false,
            actions: [
              if (vm.candidates.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.delete_outlined,
                    size: theme.textTheme.titleMedium?.fontSize,
                  ),
                  onPressed: () {},
                ),
              if (vm.candidates.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.check_outlined,
                    size: theme.textTheme.titleMedium?.fontSize,
                  ),
                  onPressed: () {
                    handleSubmit();
                  },
                ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}
