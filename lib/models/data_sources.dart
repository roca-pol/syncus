import 'models.dart';

/// A [T]s data source supports basic C.R.U.D operations.
/// * C - Create
/// * R - Read
/// * U - Update
/// * D - Delete
abstract class DataSource<T> {
  /// Create and return the newly created elements.
  Future<T> create(T element);

  /// Return all elements.
  Future<List<T>> readAll();

  /// Return a elements with the provided [id] if one exists.
  Future<T?> read(String id);

  /// Update the elements with [T] if present, and return the updated element.
  Future<T> update(T element);

  /// Delete the elements with the provided [id] if one exists.
  Future<void> delete(String id);
}

class InMemoryDataSource<T extends Identifiable> implements DataSource<T> {
  final Map<String, T> _cache = <String, T>{};

  @override
  Future<T> create(T element) async {
    _cache[element.id] = element;
    return element;
  }

  @override
  Future<List<T>> readAll() async => _cache.values.toList();

  @override
  Future<T?> read(String id) async => _cache[id];

  @override
  Future<T> update(T element) async {
    return _cache.update(element.id, (value) => element);
  }

  @override
  Future<void> delete(String id) async => _cache.remove(id);
}
