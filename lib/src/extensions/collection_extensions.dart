/// List Extensions
/// Provides useful extensions for List manipulation and operations
extension ListExtensions<T> on List<T> {
  // ==================== Safe Access ====================

  /// Safely get element at index, returns null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element or null if list is empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if list is empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Get first element matching condition or null
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// Get last element matching condition or null
  T? lastWhereOrNull(bool Function(T) test) {
    try {
      return lastWhere(test);
    } catch (e) {
      return null;
    }
  }

  // ==================== Transformations ====================

  /// Map with index
  List<R> mapIndexed<R>(R Function(int index, T element) transform) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(transform(i, this[i]));
    }
    return result;
  }

  /// Filter with index
  List<T> whereIndexed(bool Function(int index, T element) test) {
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      if (test(i, this[i])) {
        result.add(this[i]);
      }
    }
    return result;
  }

  /// Flatten nested lists
  List<R> flatten<R>() {
    final result = <R>[];
    for (final item in this) {
      if (item is List<R>) {
        result.addAll(item);
      } else if (item is R) {
        result.add(item);
      }
    }
    return result;
  }

  // ==================== Chunking & Partitioning ====================

  /// Split list into chunks of specified size
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  /// Partition list into two lists based on predicate
  (List<T>, List<T>) partition(bool Function(T) test) {
    final matched = <T>[];
    final unmatched = <T>[];
    for (final item in this) {
      if (test(item)) {
        matched.add(item);
      } else {
        unmatched.add(item);
      }
    }
    return (matched, unmatched);
  }

  /// Split list at index
  (List<T>, List<T>) splitAt(int index) {
    if (index < 0 || index > length) {
      throw RangeError('Index out of range');
    }
    return (sublist(0, index), sublist(index));
  }

  // ==================== Grouping ====================

  /// Group elements by key
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Group consecutive elements by key
  List<List<T>> groupConsecutiveBy<K>(K Function(T) keySelector) {
    if (isEmpty) return [];
    
    final groups = <List<T>>[];
    var currentGroup = <T>[first];
    var currentKey = keySelector(first);

    for (var i = 1; i < length; i++) {
      final key = keySelector(this[i]);
      if (key == currentKey) {
        currentGroup.add(this[i]);
      } else {
        groups.add(currentGroup);
        currentGroup = [this[i]];
        currentKey = key;
      }
    }
    groups.add(currentGroup);
    return groups;
  }

  // ==================== Distinct & Unique ====================

  /// Get distinct elements
  List<T> distinct() {
    return toSet().toList();
  }

  /// Get distinct elements by key
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    final result = <T>[];
    for (final item in this) {
      final key = keySelector(item);
      if (seen.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  // ==================== Set Operations ====================

  /// Get intersection with another list
  List<T> intersect(List<T> other) {
    final set = other.toSet();
    return where((item) => set.contains(item)).toList();
  }

  /// Get union with another list (distinct elements)
  List<T> union(List<T> other) {
    return [...this, ...other].distinct();
  }

  /// Get difference (elements in this but not in other)
  List<T> difference(List<T> other) {
    final set = other.toSet();
    return where((item) => !set.contains(item)).toList();
  }

  // ==================== Sorting ====================

  /// Sort by key
  List<T> sortedBy<K extends Comparable>(K Function(T) keySelector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keySelector(a).compareTo(keySelector(b)));
    return copy;
  }

  /// Sort by key descending
  List<T> sortedByDescending<K extends Comparable>(K Function(T) keySelector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keySelector(b).compareTo(keySelector(a)));
    return copy;
  }

  // ==================== Rotating & Reversing ====================

  /// Rotate list by n positions (positive = right, negative = left)
  List<T> rotate(int n) {
    if (isEmpty) return this;
    final shift = n % length;
    if (shift == 0) return this;
    if (shift > 0) {
      return [...sublist(length - shift), ...sublist(0, length - shift)];
    } else {
      return [...sublist(-shift), ...sublist(0, -shift)];
    }
  }

  /// Shuffle list (returns new list)
  List<T> shuffled() {
    final copy = List<T>.from(this);
    copy.shuffle();
    return copy;
  }

  // ==================== Aggregation ====================

  /// Reduce with initial value
  R fold<R>(R initialValue, R Function(R previous, T element) combine) {
    var value = initialValue;
    for (final element in this) {
      value = combine(value, element);
    }
    return value;
  }

  /// Count elements matching predicate
  int count([bool Function(T)? test]) {
    if (test == null) return length;
    return where(test).length;
  }

  /// Check if all elements match predicate
  bool all(bool Function(T) test) {
    return every(test);
  }

  /// Check if none of the elements match predicate
  bool none(bool Function(T) test) {
    return !any(test);
  }

  // ==================== Taking & Dropping ====================

  /// Take first n elements
  List<T> take(int n) {
    if (n <= 0) return [];
    if (n >= length) return this;
    return sublist(0, n);
  }

  /// Take last n elements
  List<T> takeLast(int n) {
    if (n <= 0) return [];
    if (n >= length) return this;
    return sublist(length - n);
  }

  /// Take elements while condition is true
  List<T> takeWhile(bool Function(T) test) {
    final result = <T>[];
    for (final item in this) {
      if (!test(item)) break;
      result.add(item);
    }
    return result;
  }

  /// Drop first n elements
  List<T> drop(int n) {
    if (n <= 0) return this;
    if (n >= length) return [];
    return sublist(n);
  }

  /// Drop last n elements
  List<T> dropLast(int n) {
    if (n <= 0) return this;
    if (n >= length) return [];
    return sublist(0, length - n);
  }

  /// Drop elements while condition is true
  List<T> dropWhile(bool Function(T) test) {
    var dropping = true;
    return where((item) {
      if (dropping && test(item)) return false;
      dropping = false;
      return true;
    }).toList();
  }

  // ==================== Intersperse ====================

  /// Insert separator between elements
  List<T> intersperse(T separator) {
    if (isEmpty) return [];
    final result = <T>[first];
    for (var i = 1; i < length; i++) {
      result.add(separator);
      result.add(this[i]);
    }
    return result;
  }

  // ==================== Utilities ====================

  /// Swap elements at two indices
  List<T> swap(int index1, int index2) {
    if (index1 < 0 || index1 >= length || index2 < 0 || index2 >= length) {
      throw RangeError('Index out of range');
    }
    final copy = List<T>.from(this);
    final temp = copy[index1];
    copy[index1] = copy[index2];
    copy[index2] = temp;
    return copy;
  }

  /// Replace element at index
  List<T> replaceAt(int index, T element) {
    if (index < 0 || index >= length) {
      throw RangeError('Index out of range');
    }
    final copy = List<T>.from(this);
    copy[index] = element;
    return copy;
  }

  /// Replace all occurrences of an element
  List<T> replaceAll(T oldElement, T newElement) {
    return map((e) => e == oldElement ? newElement : e).toList();
  }

  /// Replace elements matching predicate
  List<T> replaceWhere(bool Function(T) test, T newElement) {
    return map((e) => test(e) ? newElement : e).toList();
  }
}

/// Extension for List<num>.
extension NumListExtensions on List<num> {
  /// Get sum of all elements
  num get sum => isEmpty ? 0 : reduce((a, b) => a + b);

  /// Get average of all elements
  double get average => isEmpty ? 0 : sum / length;

  /// Get maximum value
  num get max => isEmpty ? 0 : reduce((a, b) => a > b ? a : b);

  /// Get minimum value
  num get min => isEmpty ? 0 : reduce((a, b) => a < b ? a : b);

  /// Get median value
  double get median {
    if (isEmpty) return 0;
    final sorted = List<num>.from(this)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle].toDouble();
    }
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }
}

/// Extension for List<String>
extension StringListExtensions on List<String> {
  /// Join with custom separator for last element
  /// Example: ['a', 'b', 'c'].joinWithLast(', ', ' and ') => 'a, b and c'
  String joinWithLast(String separator, String lastSeparator) {
    if (isEmpty) return '';
    if (length == 1) return first;
    return '${take(length - 1).join(separator)}$lastSeparator${last}';
  }

  /// Join with Oxford comma
  /// Example: ['a', 'b', 'c'].joinWithOxford() => 'a, b, and c'
  String joinWithOxford({String lastWord = 'and'}) {
    if (isEmpty) return '';
    if (length == 1) return first;
    if (length == 2) return '$first $lastWord $last';
    return '${take(length - 1).join(', ')}, $lastWord $last';
  }
}

/// Map Extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Safely get value with default
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  /// Filter entries by value
  Map<K, V> whereValue(bool Function(V) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.value)),
    );
  }

  /// Filter entries by key
  Map<K, V> whereKey(bool Function(K) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.key)),
    );
  }

  /// Map values
  Map<K, R> mapValues<R>(R Function(V) transform) {
    return map((key, value) => MapEntry(key, transform(value)));
  }

  /// Map keys
  Map<R, V> mapKeys<R>(R Function(K) transform) {
    return map((key, value) => MapEntry(transform(key), value));
  }

  /// Invert map (swap keys and values)
  Map<V, K> get inverted {
    return map((key, value) => MapEntry(value, key));
  }

  /// Merge with another map (other map values take precedence)
  Map<K, V> merge(Map<K, V> other) {
    return {...this, ...other};
  }

  /// Deep merge (for nested maps)
  Map<K, dynamic> deepMerge(Map<K, dynamic> other) {
    final result = Map<K, dynamic>.from(this);
    other.forEach((key, value) {
      if (value is Map && result[key] is Map) {
        result[key] = (result[key] as Map).deepMerge(value as Map);
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}