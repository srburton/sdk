// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// SharedOptions=--enable-experiment=class-modifiers

// Error when attempting to implement typedef base class outside of its library.

import 'base_class_typedef_lib.dart';

class BTypeDef implements BaseClassTypeDef {
// ^
// [analyzer] unspecified
// [cfe] unspecified
  @override
  int foo = 1;
}
