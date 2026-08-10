import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef XTileBuilder<E extends Entity> =
    Widget Function(Item<E>, {AsyncCallback? onDelete});
