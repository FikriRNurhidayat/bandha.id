import 'package:flutter/material.dart';

class AppViewModelBuilder<T extends Listenable> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget Function(BuildContext context, T viewModel) builder;

  const AppViewModelBuilder({
    super.key,
    required this.create,
    required this.builder,
  });

  @override
  State<AppViewModelBuilder<T>> createState() => _AppViewModelBuilderState<T>();
}

class _AppViewModelBuilderState<T extends Listenable>
    extends State<AppViewModelBuilder<T>> {
  T? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _viewModel ??= widget.create(context);
  }

  @override
  void dispose() {
    if (_viewModel is ChangeNotifier) {
      (_viewModel as ChangeNotifier).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;

    return ListenableBuilder(
      key: widget.key,
      listenable: vm,
      builder: (context, _) {
        return widget.builder(context, vm);
      },
    );
  }
}
