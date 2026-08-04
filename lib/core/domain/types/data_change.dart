class DataChange<T> {
  final T before;
  final T after;

  const DataChange(this.before, this.after);
}

class DataChangeList<T> extends Iterable<DataChange<T>> {
  final List<DataChange<T>> dataChanges;

  DataChangeList(this.dataChanges);

  Iterable<T> get before => dataChanges.map((dataChange) => dataChange.before);
  Iterable<T> get after => dataChanges.map((dataChange) => dataChange.after);

  DataChangeList<T> add(T before, T after) {
    dataChanges.add(DataChange<T>(before, after));

    return this;
  }

  @override
  Iterator<DataChange<T>> get iterator => dataChanges.iterator;

  @override
  bool get isEmpty => dataChanges.isEmpty;

  @override
  bool get isNotEmpty => dataChanges.isNotEmpty;

  @override
  int get length => dataChanges.length;
}

class DataChangeSet<T> {
  final List<T> createList = [];
  final DataChangeList<T> updateList = DataChangeList<T>([]);
  final List<T> destroyList = [];

  DataChangeSet();

  T create(T data) {
    createList.add(data);
    return data;
  }

  T update(T before, T after) {
    updateList.add(before, after);
    return after;
  }

  void destroy(T data) {
    destroyList.add(data);
  }

  bool get isEmpty =>
      createList.isEmpty && updateList.isEmpty && destroyList.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get shouldCreate => createList.isNotEmpty;
  bool get shouldUpdate => updateList.isNotEmpty;
  bool get shouldDestroy => destroyList.isNotEmpty;
}
