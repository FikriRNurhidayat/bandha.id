import 'dart:async';

import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/presentation/view_models/classifier_select_view_model.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:flutter/material.dart';

// TODO: Seperate value selection with ui selection for delete, or edit action.
class ClassifierSelectView<T extends Classifier<T>> extends StatefulWidget {
  const ClassifierSelectView({
    super.key,
    required this.vmResolver,
    this.multiple = false,
  });

  final ClassifierSelectViewModel<T> Function() vmResolver;
  final bool multiple;

  factory ClassifierSelectView.builder(BuildContext context) {
    return ClassifierSelectView<T>(
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
  Timer? debounceTimer;

  @override
  initState() {
    vm.setFilter({"readonly_eq": false});
    vm.query();
    super.initState();
  }

  @override
  dispose() {
    vm.dispose();
    controller.dispose();
    debounceTimer?.cancel();
    super.dispose();
  }

  void handleSubmit() async {
    if (!vm.hasData || vm.requireData.isEmpty) {
      await vm.create(controller.text);
      controller.value = TextEditingValue.empty;
      handleTextChange(controller.text);
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

        if (vm.hasData && vm.requireData.length == 1) {
          await vm.resetSelection();
          await vm.select(vm.requireData.first);
        }
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
                    controller: controller,
                    onChanged: handleTextChange,
                    textInputAction: TextInputAction.send,
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

              return ListTile(
                dense: true,
                leading: Icon(
                  item.isSelected ? Icons.label : Icons.label_outlined,
                ),
                title: Text(item.entity.name),
                trailing: widget.multiple
                    ? Checkbox(
                        value: item.isSelected,
                        onChanged: (bool? value) async {
                          if (value == null) return;
                          if (value) {
                            await vm.select(item);
                          } else {
                            await vm.deselect(item);
                          }
                        },
                      )
                    : Radio<Item<T>>(value: item),
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
            actionsPadding: EdgeInsets.only(left: 24, right: 24),
            actions: [
              if (vm.candidates.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.check_outlined),
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
