import 'package:hive_flutter/hive_flutter.dart';
import '../models/person.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static const String _boxName = 'personsBox';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<Person> getAllPersons() {
    try {
      return _box.values.map((data) {
        // Приводим data к Map для безопасного парсинга
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        return Person.fromJson(mapData);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Person getPersonById(String id) {
    final data = _box.get(id);
    return Person.fromJson(data as Map<dynamic, dynamic>);
  }

  Future<void> savePerson(Person person) async {
    await _box.put(person.id, person.toJson());
  }

  Future<void> deletePerson(String id) async {
    await _box.delete(id);
  }
}