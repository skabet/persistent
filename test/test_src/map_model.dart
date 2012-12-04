// Copyright 2012 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: Paul Brauner (polux@google.com)

part of test_util;

/**
 * Naive implementation of PersistentMap using dart:core [Map]s.
 */
class ModelMap<K, V> extends PersistentMapBase<K, V> {
  final Map<K, V> map;

  ModelMap(this.map);

  bool get isEmpty => map.isEmpty;

  PersistentMap<K, V> insert(K key, V value, [V combine(V x, V y)]) {
    combine = (combine != null) ? combine : (V x, V y) => y;
    Map<K, V> newmap = new Map<K, V>.from(map);
    newmap[key] = map.containsKey(key) ? combine(map[key], value) : value;
    return new ModelMap(newmap);
  }

  PersistentMap<K, V> delete(K key) {
    Map<K, V> newmap = new Map<K, V>.from(map);
    newmap.remove(key);
    return new ModelMap(newmap);
  }

  Option<V> lookup(K key) {
    if (map.containsKey(key)) {
      return new Option<V>.some(map[key]);
    } else {
      return new Option<V>.none();
    }
  }

  PersistentMap mapValues(f(V)) {
    Map newmap = new Map.from(map);
    map.forEach((K key, V value) {
      newmap[key] = f(value);
    });
    return new ModelMap(newmap);
  }

  PersistentMap<K, V> adjust(K key, V update(V)) {
    if (map.containsKey(key)) {
      Map newmap = new Map.from(map);
      newmap[key] = update(map[key]);
      return new ModelMap(newmap);
    }
    return this;
  }

  void forEach(f(K, V)) {
    map.forEach(f);
  }

  String toString() => map.toString();

  int get length => map.length;

  PersistentMap<K, V> union(ModelMap<K, V> other, [V combine(V x, V y)]) {
    if (combine == null) { combine = (x, y) => y; }
    Map newmap = new Map.from(map);
    other.map.forEach((K key, V value) {
      newmap[key] = newmap.containsKey(key)
          ? combine(newmap[key], value)
          : value;
    });
    return new ModelMap(newmap);
  }

  PersistentMap<K, V> intersection(ModelMap<K, V> other,
                                   [V combine(V x, V y)]) {
    if (combine == null) { combine = (x, y) => y; }
    Map newmap = new Map();
    map.forEach((K key, V value) {
      if (other.map.containsKey(key)) {
        newmap[key] = combine(value, other.map[key]);
      }
    });
    return new ModelMap(newmap);
  }
}
