/*
 * Copyright 2019 Pedro Massango.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library injectorio;

import 'bean_registry.dart' show DefinitionRegistry;
import 'models.dart';
import 'module_injector.dart';
export 'component_binder.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

final InjectorIO io = InjectorIO._internal();
DefinitionRegistry get registry => io._registry;

class InjectorIO {
  late DefinitionRegistry _registry;
  InjectorMode _mode = InjectorMode.DEBUG;

  InjectorIO._internal() {
    _registry = DefinitionRegistry.build(_mode);
  }

  factory InjectorIO.start({InjectorMode mode = InjectorMode.DEBUG}) {
    io._mode = mode;
    io._registry = DefinitionRegistry.build(mode);
    if (mode == InjectorMode.DEBUG) {
      logger.d("Initiated InjectorIO in mode: $mode");
    }
    return io;
  }

  InjectorIO _register(Definition d) {
    _registry.register(d);
    if (_mode == InjectorMode.DEBUG) {
      logger.d("Registered definition : $d");
    }
    return this;
  }

  /// Register a singleton instance
  InjectorIO single<T>(T def) =>
      this._register(Definition(Kind.SINGLE, () => def));

  /// Register a factory instance
  InjectorIO factory<T>(DefBuilder<T> defFunc) =>
      this._register(Definition(Kind.FACTORY, defFunc));

  /// Register a new module dependency
  InjectorIO module(Module module) {
    module.kDef().forEach((_, v) => this._register(v));
    if (_mode == InjectorMode.DEBUG) {
      logger.d("Succesfully registered module : $module");
    }
    return this;
  }
}
