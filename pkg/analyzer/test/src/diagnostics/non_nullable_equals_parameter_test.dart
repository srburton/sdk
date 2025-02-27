// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/utilities/legacy.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NonNullableEqualsParameterTest);
  });
}

@reflectiveTest
class NonNullableEqualsParameterTest extends PubPackageResolutionTest {
  test_dynamic() async {
    await assertErrorsInCode(r'''
class C {
  @override
  bool operator ==(dynamic other) => false;
}
''', [
      error(StaticWarningCode.NON_NULLABLE_EQUALS_PARAMETER, 38, 2),
    ]);
  }

  test_inheritedDynamic() async {
    await assertErrorsInCode(r'''
class C {
  @override
  bool operator ==(dynamic other) => false;
}
class D extends C {
  @override
  bool operator ==(other) => false;
}
''', [
      error(StaticWarningCode.NON_NULLABLE_EQUALS_PARAMETER, 38, 2),
      error(StaticWarningCode.NON_NULLABLE_EQUALS_PARAMETER, 116, 2),
    ]);
  }

  test_inheritedFromObject() async {
    await assertNoErrorsInCode(r'''
class C {
  @override
  bool operator ==(other) => false;
}
''');
  }

  test_inheritedFromObject_preNullSafe() async {
    try {
      noSoundNullSafety = false;
      await assertNoErrorsInCode(r'''
// @dart=2.9
class C {
  @override
  bool operator ==(other) => false;
}
''');
    } finally {
      noSoundNullSafety = true;
    }
  }

  test_int() async {
    await assertNoErrorsInCode(r'''
class C {
  @override
  bool operator ==(covariant int other) => false;
}
''');
  }

  test_nullableObject() async {
    await assertErrorsInCode(r'''
class C {
  @override
  bool operator ==(Object? other) => false;
}
''', [
      error(StaticWarningCode.NON_NULLABLE_EQUALS_PARAMETER, 38, 2),
    ]);
  }

  test_object() async {
    await assertNoErrorsInCode(r'''
class C {
  @override
  bool operator ==(Object other) => false;
}
''');
  }
}
