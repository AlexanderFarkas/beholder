import 'dart:math';

import 'package:beholder/beholder.dart';

extension ObservableListX<T> on ObservableState<List<T>> {
  void add(T item) {
    value.add(item);
    invalidate();
  }

  bool remove(T item) {
    final result = value.remove(item);
    invalidate();
    return result;
  }

  void clear() {
    value.clear();
    invalidate();
  }

  void addAll(Iterable<T> items) {
    value.addAll(items);
    invalidate();
  }

  void removeWhere(bool Function(T element) test) {
    value.removeWhere(test);
    invalidate();
  }

  void retainWhere(bool Function(T element) test) {
    value.retainWhere(test);
    invalidate();
  }

  void sort([int Function(T a, T b)? compare]) {
    value.sort(compare);
    invalidate();
  }

  void shuffle([Random? random]) {
    value.shuffle(random);
    invalidate();
  }

  void insert(int index, T element) {
    value.insert(index, element);
    invalidate();
  }

  void insertAll(int index, Iterable<T> iterable) {
    value.insertAll(index, iterable);
    invalidate();
  }

  void setAll(int index, Iterable<T> iterable) {
    value.setAll(index, iterable);
    invalidate();
  }

  void removeAt(int index) {
    value.removeAt(index);
    invalidate();
  }

  T removeLast() {
    final result = value.removeLast();
    invalidate();
    return result;
  }

  void removeRange(int start, int end) {
    value.removeRange(start, end);
    invalidate();
  }

  void replaceRange(int start, int end, Iterable<T> replacement) {
    value.replaceRange(start, end, replacement);
    invalidate();
  }

  void fillRange(int start, int end, [T? fillValue]) {
    value.fillRange(start, end, fillValue);
    invalidate();
  }

  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    value.setRange(start, end, iterable, skipCount);
    invalidate();
  }
}

extension ObservableSet<T> on ObservableState<Set<T>> {
  bool add(T value) {
    final result = this.value.add(value);
    if (result) {
      invalidate();
    }
    return result;
  }

  void addAll(Iterable<T> elements) {
    value.addAll(elements);
    invalidate();
  }

  bool remove(T value) {
    final result = this.value.remove(value);
    invalidate();
    return result;
  }

  void removeAll(Iterable<T> elements) {
    value.removeAll(elements);
    invalidate();
  }

  void retainAll(Iterable<T> elements) {
    value.retainAll(elements);
    invalidate();
  }

  void removeWhere(bool Function(T element) test) {
    value.removeWhere(test);
    invalidate();
  }

  void retainWhere(bool Function(T element) test) {
    value.retainWhere(test);
    invalidate();
  }

  void clear() {
    value.clear();
    invalidate();
  }
}

extension ObservableMap<K, V> on ObservableState<Map<K, V>> {
  void operator []=(K key, V value) {
    this.value[key] = value;
    invalidate();
  }

  void addAll(Map<K, V> other) {
    value.addAll(other);
    invalidate();
  }

  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    value.addEntries(newEntries);
    invalidate();
  }

  void clear() {
    value.clear();
    invalidate();
  }

  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final result = value.update(key, update, ifAbsent: ifAbsent);
    invalidate();
    return result;
  }

  void updateAll(V Function(K key, V value) update) {
    value.updateAll(update);
    invalidate();
  }

  V putIfAbsent(K key, V Function() ifAbsent) {
    final result = value.putIfAbsent(key, ifAbsent);
    invalidate();
    return result;
  }

  V? remove(Object? key) {
    final result = value.remove(key);
    invalidate();
    return result;
  }

  void removeWhere(bool Function(K key, V value) predicate) {
    value.removeWhere(predicate);
    invalidate();
  }
}
