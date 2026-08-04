import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/modules/classifiers/application/use_cases/create_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/destroy_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/get_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/query_classifiers.dart';
import 'package:bandha/modules/classifiers/application/use_cases/update_classifier.dart';
import 'package:bandha/modules/classifiers/data/data_sources/category_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/category_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/label_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/label_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/party_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/party_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/repositories/category_repository_impl.dart';
import 'package:bandha/modules/classifiers/data/repositories/label_repository_impl.dart';
import 'package:bandha/modules/classifiers/data/repositories/party_repository_impl.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/party_reader.dart';
import 'package:bandha/modules/classifiers/domain/repositories/category_repository.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';
import 'package:bandha/modules/classifiers/domain/repositories/label_repository.dart';
import 'package:bandha/modules/classifiers/domain/repositories/party_repository.dart';

class ClassifierModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<CategorySqliteStorage>(
      CategorySqliteStorage.fromContainer(c),
    );
    c.registerSingleton<LabelSqliteStorage>(
      LabelSqliteStorage.fromContainer(c),
    );
    c.registerSingleton<PartySqliteStorage>(
      PartySqliteStorage.fromContainer(c),
    );

    c.registerSingleton<CategoryLocalStorage>(c.get<CategorySqliteStorage>());
    c.registerSingleton<LabelLocalStorage>(c.get<LabelSqliteStorage>());
    c.registerSingleton<PartyLocalStorage>(c.get<PartySqliteStorage>());

    c.registerSingleton<CategoryRepositoryImpl>(
      CategoryRepositoryImpl.fromContainer(c),
    );
    c.registerSingleton<LabelRepositoryImpl>(
      LabelRepositoryImpl.fromContainer(c),
    );
    c.registerSingleton<PartyRepositoryImpl>(
      PartyRepositoryImpl.fromContainer(c),
    );

    c.registerSingleton<CategoryRepository>(c.get<CategoryRepositoryImpl>());
    c.registerSingleton<LabelRepository>(c.get<LabelRepositoryImpl>());
    c.registerSingleton<PartyRepository>(c.get<PartyRepositoryImpl>());
    c.registerSingleton<ClassifierRepository<Category>>(
      c.get<CategoryRepositoryImpl>(),
    );
    c.registerSingleton<ClassifierRepository<Label>>(
      c.get<LabelRepositoryImpl>(),
    );
    c.registerSingleton<ClassifierRepository<Party>>(
      c.get<PartyRepositoryImpl>(),
    );

    c.registerSingleton<CategoryReader>(c.get<CategoryRepositoryImpl>());
    c.registerSingleton<LabelReader>(c.get<LabelRepositoryImpl>());
    c.registerSingleton<PartyReader>(c.get<PartyRepositoryImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateClassifier<Category>>(
      CreateClassifier<Category>.fromContainer(c, factory: Category.create),
    );
    c.registerSingleton<CreateClassifier<Label>>(
      CreateClassifier<Label>.fromContainer(c, factory: Label.create),
    );
    c.registerSingleton<CreateClassifier<Party>>(
      CreateClassifier<Party>.fromContainer(c, factory: Party.create),
    );

    c.registerSingleton<UpdateClassifier<Category>>(
      UpdateClassifier<Category>.fromContainer(c),
    );
    c.registerSingleton<UpdateClassifier<Label>>(
      UpdateClassifier<Label>.fromContainer(c),
    );
    c.registerSingleton<UpdateClassifier<Party>>(
      UpdateClassifier<Party>.fromContainer(c),
    );

    c.registerSingleton<DestroyClassifier<Category>>(
      DestroyClassifier<Category>.fromContainer(c),
    );
    c.registerSingleton<DestroyClassifier<Label>>(
      DestroyClassifier<Label>.fromContainer(c),
    );
    c.registerSingleton<DestroyClassifier<Party>>(
      DestroyClassifier<Party>.fromContainer(c),
    );

    c.registerSingleton<GetClassifier<Category>>(
      GetClassifier<Category>.fromContainer(c),
    );
    c.registerSingleton<GetClassifier<Label>>(
      GetClassifier<Label>.fromContainer(c),
    );
    c.registerSingleton<GetClassifier<Party>>(
      GetClassifier<Party>.fromContainer(c),
    );

    c.registerSingleton<QueryClassifiers<Category>>(
      QueryClassifiers<Category>.fromContainer(c),
    );
    c.registerSingleton<QueryClassifiers<Label>>(
      QueryClassifiers<Label>.fromContainer(c),
    );
    c.registerSingleton<QueryClassifiers<Party>>(
      QueryClassifiers<Party>.fromContainer(c),
    );
  }
}
