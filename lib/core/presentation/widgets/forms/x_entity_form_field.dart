import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_selector_provider.dart';
import 'package:bandha/core/presentation/widgets/decorations/x_input_styles.dart';
import 'package:bandha/core/presentation/widgets/observers/keyboard_observer.dart';
import 'package:flutter/material.dart';

typedef XEntityFormFieldProviderBuilder<E extends Entity> =
    AsyncSelectorProvider<E> Function();

typedef XEntityFormFieldActionBuilder<E extends Entity> =
    List<Widget> Function(BuildContext context, XEntityFormFieldState<E> state);

class XEntityFormField<E extends Entity> extends FormField<Item<E>> {
  late final XEntityFormFieldProviderBuilder resolveProvider;
  final XEntityFormFieldActionBuilder? actionsBuilder;
  final String labelText;
  final String? hintText;
  final Widget Function(BuildContext context, Item<E> i) labelBuilder;
  final bool readOnly;
  final bool autofocus;

  XEntityFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.enabled,
    super.initialValue,
    this.readOnly = false,
    this.autofocus = false,
    this.hintText,
    required this.resolveProvider,
    required this.labelText,
    required this.labelBuilder,
    this.actionsBuilder,
  }) : super(
         builder: (state) {
           state as XEntityFormFieldState<E>;

           return Focus(
             autofocus: autofocus,
             focusNode: state._focusNode,
             child: Builder(
               builder: (context) {
                 final theme = Theme.of(context);

                 return ValueListenableBuilder(
                   valueListenable: state.provider.notifier,
                   builder: (context, snapshot, child) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return Center(child: CircularProgressIndicator());
                     }

                     if (snapshot.hasError) {
                       return ListView(
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
                     }

                     return state._builder(context);
                   },
                 );
               },
             ),
           );
         },
       );

  @override
  FormFieldState<Item<E>> createState() => XEntityFormFieldState<E>();
}

class XEntityFormFieldState<E extends Entity> extends FormFieldState<Item<E>> {
  XEntityFormField<E> get view => widget as XEntityFormField<E>;
  late final AsyncSelectorProvider<E> provider =
      view.resolveProvider() as AsyncSelectorProvider<E>;
  late final _focusNode = FocusNode();
  PersistentBottomSheetController? _bottomSheetController;

  bool get hasSelected => selected != null;

  Item<E>? get selected {
    for (final i in provider.data ?? <Item<E>>[]) {
      if (i.isSelected) return i;
    }

    return null;
  }

  @override
  initState() {
    super.initState();

    if (widget.initialValue != null) {
      provider.initialValue(widget.initialValue!);
    } else {
      provider.query();
    }

    _focusNode.addListener(_focusListener);
  }

  Widget _builder(BuildContext context) {
    return InputDecorator(
      decoration: XInputStyles.field(labelText: view.labelText),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: _chipBuilder(context),
      ),
    );
  }

  List<Widget> _chipBuilder(BuildContext context) {
    final List<Widget> chips = !view.readOnly
        ? []
        : [view.labelBuilder(context, view.initialValue!)];

    if (provider.hasData && !view.readOnly) {
      chips.addAll(
        provider.requireData.map(
          (i) => ChoiceChip(
            label: view.labelBuilder(context, i),
            selected: i.isSelected,
            onSelected: (v) {
              didChange(i);
              provider.select(i);
            },
          ),
        ),
      );
    }

    if (!view.readOnly && view.actionsBuilder != null) {
      chips.addAll(view.actionsBuilder!.call(context, this));
    }

    return chips;
  }

  Widget _bottomSheetBuilder(BuildContext context, double height) {
    return SafeArea(
      bottom: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ValueListenableBuilder(
            //   valueListenable: provider.notifier,
            //   builder: (_, _, _) {
            //     return Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: InputDecorator(
            //         decoration: XInputStyles.field(labelText: view.labelText),
            //         child: hasSelected
            //             ? view.labelBuilder(context, selected!)
            //             : Text(
            //                 view.hintText ?? "Select options...",
            //                 style: TextStyle(
            //                   color: Theme.of(context).hintColor,
            //                 ),
            //               ),
            //       ),
            //     );
            //   },
            // ),
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton(
                  onPressed: () {
                    if (!context.mounted) return;
                    if (_focusNode.hasFocus) _focusNode.previousFocus();
                  },
                  icon: Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: height,
              padding: EdgeInsets.all(16.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ValueListenableBuilder(
                valueListenable: provider.notifier,
                builder: (context, value, child) {
                  return Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: _chipBuilder(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _focusListener() {
    if (!mounted) return;

    if (_focusNode.hasFocus) {
      final height = KeyboardObserver.height > 0
          ? KeyboardObserver.height
          : 250.0;

      _bottomSheetController = Scaffold.of(context).showBottomSheet(
        (context) => _bottomSheetBuilder(context, height),
        constraints: BoxConstraints(maxWidth: double.infinity),
        shape: const RoundedRectangleBorder(),
        sheetAnimationStyle: AnimationStyle.noAnimation,
      );
    } else {
      _bottomSheetController?.close();
      _bottomSheetController = null;
    }
  }

  @override
  dispose() {
    _focusNode.removeListener(_focusListener);
    provider.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
