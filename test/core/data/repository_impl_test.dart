import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/core_helpers.dart';

class ThingRepository extends RepositoryImpl<Thing> {
  @override
  final FakeLocalStorage<Thing> localStorage = FakeLocalStorage<Thing>();
}

class HydratedThingRepository extends HydratedRepositoryImpl<Thing> {
  @override
  final FakeLocalStorage<Thing> localStorage = FakeLocalStorage<Thing>();
  @override
  final ThingHydrator hydrator = ThingHydrator();
}

void main() {
  group("RepositoryImpl", () {
    late ThingRepository repo;
    setUp(() => repo = ThingRepository());

    test("getAll with no ids skips storage", () async {
      expect(await repo.getAll([]), isEmpty);
      expect(repo.localStorage.calls, isEmpty);
    });

    test("getAll queries by id_in", () async {
      repo.localStorage.findAllResult = [Thing("a")];
      final result = await repo.getAll(["a", "b"]);
      expect(result.map((t) => t.id), ["a"]);
      expect(repo.localStorage.filters.single, {
        "id_in": ["a", "b"],
      });
    });

    test("get queries by id_eq", () async {
      final thing = Thing("a");
      repo.localStorage.findResult = thing;
      expect(await repo.get("a"), same(thing));
      expect(repo.localStorage.filters.single, {"id_eq": "a"});
    });

    test("get throws when not found", () async {
      await expectLater(repo.get("a"), throwsException);
    });

    test("save and saveAll return their input", () async {
      final thing = Thing("a");
      final things = [Thing("b"), Thing("c")];
      expect(await repo.save(thing), same(thing));
      expect(await repo.saveAll(things), same(things));
      expect(repo.localStorage.calls, ["save", "saveAll"]);
      expect(repo.localStorage.args, [thing, things]);
    });

    test("find and findAll delegate the filter", () async {
      repo.localStorage.findResult = Thing("a");
      repo.localStorage.findAllResult = [Thing("a"), Thing("b")];
      expect((await repo.find({"x": 1}))?.id, "a");
      expect(await repo.findAll({"y": 2}), hasLength(2));
      expect(repo.localStorage.filters, [
        {"x": 1},
        {"y": 2},
      ]);
    });

    test("find returns null when storage has none", () async {
      expect(await repo.find({"x": 1}), isNull);
    });

    test("destroy and destroyAll delegate", () async {
      final thing = Thing("a");
      final things = [Thing("b")];
      await repo.destroy(thing);
      await repo.destroyAll(things);
      expect(repo.localStorage.calls, ["destroy", "destroyAll"]);
      expect(repo.localStorage.args, [thing, things]);
    });

    test("query delegates and returns the storage list", () async {
      final list = DataList<Thing>(
        hasNext: true,
        hasPrevious: false,
        hits: [Thing("a")],
      );
      repo.localStorage.queryResult = list;
      final query = DataQuery(size: 2);
      expect(await repo.query(query), same(list));
      expect(repo.localStorage.queries.single, same(query));
    });
  });

  group("HydratedRepositoryImpl", () {
    late HydratedThingRepository repo;
    setUp(() => repo = HydratedThingRepository());

    test("get hydrates the entity", () async {
      repo.localStorage.findResult = Thing("a");
      final result = await repo.get("a");
      expect(result.hydrated, isTrue);
      expect(repo.hydrator.hydrateCalls, 1);
    });

    test("get throws without hydrating when missing", () async {
      await expectLater(repo.get("a"), throwsException);
      expect(repo.hydrator.hydrateCalls, 0);
    });

    test("getAll hydrates all", () async {
      repo.localStorage.findAllResult = [Thing("a"), Thing("b")];
      final result = await repo.getAll(["a", "b"]);
      expect(result.every((t) => t.hydrated), isTrue);
      expect(repo.hydrator.hydrateAllCalls, 1);
    });

    test("getAll with no ids returns empty", () async {
      expect(await repo.getAll([]), isEmpty);
      expect(repo.localStorage.calls, isEmpty);
    });

    test("find hydrates a hit", () async {
      repo.localStorage.findResult = Thing("a");
      expect((await repo.find({}))!.hydrated, isTrue);
    });

    test("find returns null without hydrating", () async {
      expect(await repo.find({}), isNull);
      expect(repo.hydrator.hydrateCalls, 0);
    });

    test("findAll hydrates all", () async {
      repo.localStorage.findAllResult = [Thing("a")];
      final result = await repo.findAll({"x": 1});
      expect(result.single.hydrated, isTrue);
      expect(repo.localStorage.filters.single, {"x": 1});
    });

    test("query hydrates hits and keeps paging info", () async {
      final next = DataCursor(direction: DataCursorDirection.next, values: {});
      repo.localStorage.queryResult = DataList<Thing>(
        next: next,
        hasNext: true,
        hasPrevious: false,
        hits: [Thing("a"), Thing("b")],
      );
      final result = await repo.query(DataQuery());
      expect(result.every((t) => t.hydrated), isTrue);
      expect(result.map((t) => t.id), ["a", "b"]);
      expect(result.hasNext, isTrue);
      expect(result.hasPrevious, isFalse);
      expect(result.next, same(next));
    });

    test("save is not hydrated", () async {
      final result = await repo.save(Thing("a"));
      expect(result.hydrated, isFalse);
    });
  });
}
