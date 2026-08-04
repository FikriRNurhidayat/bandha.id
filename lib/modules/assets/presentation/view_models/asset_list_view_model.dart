import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/presentation/view_models/list_view_model.dart';
import 'package:bandha/core/types/pager.dart';
import 'package:bandha/modules/assets/application/use_cases/destroy_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/query_assets.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/models/asset_ui_model.dart';
import 'package:flutter/material.dart';

class AssetListViewModel extends ListViewModel<AssetUiModel> {
  final QueryAssets _queryAssets;
  final DestroyAsset _destroyAsset;

  AssetListViewModel(this._queryAssets, this._destroyAsset) : _pager = Pager();

  factory AssetListViewModel.fromContainer(DependencyContainer c) {
    return AssetListViewModel(
      c.get<QueryAssets>(),
      c.get<DestroyAsset>(),
    );
  }

  factory AssetListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AssetListViewModel>();
  }

  @override
  bool get hasNext {
    return _hasNext;
  }

  @override
  bool get hasPrevious {
    return _hasPrevious;
  }

  @override
  Object? get error {
    return _error;
  }

  @override
  bool get isEmpty {
    return _isEmpty;
  }

  @override
  bool get isError {
    return _isError;
  }

  @override
  bool get isLoading {
    return _isLoading;
  }

  @override
  List<AssetUiModel> get hits {
    return _pager.toList();
  }

  @override
  void applyFilter(DataFilter? filter) {
    _filter = filter;
    notifyListeners();
  }

  @override
  void resetFilter() {
    _filter = null;
    notifyListeners();
  }

  @override
  Future<void> query() async {
    _isLoading = true;
    notifyListeners();

    try {
      final assets = _apply(
        await _queryAssets.execute(QueryEntitiesParams(filter: _filter)),
      );
      _pager.current = AssetUiModel.fromAssetList(assets);
      _isEmpty = _pager.isEmpty;
    } catch (error) {
      _isEmpty = true;
      _isError = true;
      _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> next() async {
    _isLoading = true;
    notifyListeners();

    try {
      final assets = _apply(
        await _queryAssets.execute(
          QueryEntitiesParams(filter: _filter, cursor: _next),
        ),
      );

      _pager.next = AssetUiModel.fromAssetList(assets);
      _isEmpty = _pager.isEmpty;
    } catch (error) {
      _isError = true;
      _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> previous() async {
    _isLoading = true;
    notifyListeners();

    try {
      final assets = _apply(
        await _queryAssets.execute(
          QueryEntitiesParams(filter: _filter, cursor: _previous),
        ),
      );

      _pager.previous = AssetUiModel.fromAssetList(assets);
      _isEmpty = _pager.isEmpty;
    } catch (error) {
      _isError = true;
      _error = error;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> destroy(AssetUiModel model) async {
    model.isLoading = true;
    notifyListeners();

    try {
      await _destroyAsset.execute(DestroyAssetParams(model.asset.id));
      model.isDeleted = true;
    } catch (error) {
      model.isLoading = false;
      model.isDeleted = false;
      model.isError = true;
      model.error = error;
    }

    model.isLoading = false;
    notifyListeners();
  }

  bool _isEmpty = true;
  bool _isError = false;
  bool _isLoading = false;
  Object? _error;
  bool _hasNext = false;
  bool _hasPrevious = false;

  final Pager<AssetUiModel> _pager;

  DataCursor? _next;
  DataCursor? _previous;
  DataFilter? _filter;

  List<Asset> _apply(DataList<Asset> assets) {
    _next = assets.next;
    _previous = assets.previous;

    _hasNext = assets.hasNext;
    _hasPrevious = assets.hasPrevious;

    return assets.toList();
  }
}
