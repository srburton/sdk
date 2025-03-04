// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/fix.dart';
import 'package:analysis_server/src/services/linter/lint_names.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'fix_processor.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RemoveComparisonTest);
    defineReflectiveTests(RemoveNullCheckComparisonTest);
    defineReflectiveTests(RemoveNullCheckComparisonBulkTest);
  });
}

@reflectiveTest
class RemoveComparisonTest extends FixProcessorTest {
  @override
  FixKind get kind => DartFixKind.REMOVE_COMPARISON;

  Future<void> test_assertInitializer_first() async {
    await resolveTestCode('''
class C {
  String t;
  C(String s) : assert(s != null), t = s;
}
''');
    await assertHasFix('''
class C {
  String t;
  C(String s) : t = s;
}
''');
  }

  Future<void> test_assertInitializer_last() async {
    await resolveTestCode('''
class C {
  String t;
  C(String s) : t = s, assert(s != null);
}
''');
    await assertHasFix('''
class C {
  String t;
  C(String s) : t = s;
}
''');
  }

  Future<void> test_assertInitializer_middle() async {
    await resolveTestCode('''
class C {
  String t;
  String u;
  C(String s) : t = s, assert(s != null), u = s;
}
''');
    await assertHasFix('''
class C {
  String t;
  String u;
  C(String s) : t = s, u = s;
}
''');
  }

  Future<void> test_assertInitializer_only() async {
    await resolveTestCode('''
class C {
  C(String s) : assert(s != null);
}
''');
    await assertHasFix('''
class C {
  C(String s);
}
''');
  }

  Future<void> test_assertStatement() async {
    await resolveTestCode('''
void f(String s) {
  assert(s != null);
  print(s);
}
''');
    await assertHasFix('''
void f(String s) {
  print(s);
}
''');
  }

  Future<void> test_binaryExpression_and_left() async {
    await resolveTestCode('''
void f(String s) {
  print(s != null && s.isNotEmpty);
}
''');
    await assertHasFix('''
void f(String s) {
  print(s.isNotEmpty);
}
''');
  }

  Future<void> test_binaryExpression_and_right() async {
    await resolveTestCode('''
void f(String s) {
  print(s.isNotEmpty && s != null);
}
''');
    await assertHasFix('''
void f(String s) {
  print(s.isNotEmpty);
}
''');
  }

  Future<void> test_binaryExpression_or_left() async {
    await resolveTestCode('''
void f(String s) {
  print(s == null || s.isEmpty);
}
''');
    await assertHasFix('''
void f(String s) {
  print(s.isEmpty);
}
''');
  }

  Future<void> test_binaryExpression_or_right() async {
    await resolveTestCode('''
void f(String s) {
  print(s.isEmpty || s == null);
}
''');
    await assertHasFix('''
void f(String s) {
  print(s.isEmpty);
}
''');
  }

  Future<void> test_ifStatement_thenBlock() async {
    await resolveTestCode('''
void f(String s) {
  if (s != null) {
    print(s);
  }
}
''');
    await assertHasFix('''
void f(String s) {
  print(s);
}
''');
  }

  Future<void> test_ifStatement_thenBlock_empty() async {
    await resolveTestCode('''
void f(String s) {
  if (s != null) {
  }
}
''');
    await assertHasFix('''
void f(String s) {
}
''');
  }

  Future<void> test_ifStatement_thenStatement() async {
    await resolveTestCode('''
void f(String s) {
  if (s != null)
    print(s);
}
''');
    await assertHasFix('''
void f(String s) {
  print(s);
}
''');
  }
}

@reflectiveTest
class RemoveNullCheckComparisonBulkTest extends BulkFixProcessorTest {
  @override
  String get lintCode => LintNames.avoid_null_checks_in_equality_operators;

  Future<void> test_singleFile() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(Object? other) =>
          other != null &&
          other is Person &&
          name == other.name;
}

class Person2 {
  final String name = '';

  @override
  operator ==(Object? other) =>
          other != null &&
          other is Person &&
          name == other.name;
}
''');
    await assertHasFix('''
class Person {
  final String name = '';

  @override
  operator ==(Object? other) =>
          other is Person &&
          name == other.name;
}

class Person2 {
  final String name = '';

  @override
  operator ==(Object? other) =>
          other is Person &&
          name == other.name;
}
''');
  }

  @FailingTest(reason: 'Only the first comparison is removed')
  Future<void> test_singleFile_overlapping() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(other) =>
          other != null &&
          other != null &&
          other is Person &&
          name == other.name;
}
''');
    await assertHasFix('''
class Person {
  final String name = '';

  @override
  operator ==(other) =>
          other is Person &&
          name == other.name;
}
''');
  }
}

@reflectiveTest
class RemoveNullCheckComparisonTest extends FixProcessorLintTest {
  @override
  FixKind get kind => DartFixKind.REMOVE_COMPARISON;

  @override
  String get lintCode => LintNames.avoid_null_checks_in_equality_operators;

  Future<void> test_expressionBody() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) =>
          other != null &&
          other is Person &&
          name == other.name;
}
''');
    await assertHasFix('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) =>
          other is Person &&
          name == other.name;
}
''');
  }

  Future<void> test_functionBody() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    return other != null &&
          other is Person &&
          name == other.name;
  }
}
''');
    await assertHasFix('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    return other is Person &&
          name == other.name;
  }
}
''');
  }

  Future<void> test_ifNullAssignmentStatement() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    if (other is! Person) return false;
    other ??= Person();
    return other.name == name;
  }
}
''');
    await assertNoFix();
  }

  /// todo(pq): consider implementing
  @FailingTest(reason: 'Fix unimplemented')
  Future<void> test_ifNullStatement() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    if (other is! Person) return false;
    final toCompare = other ?? Person();
    return toCompare.name == name;
  }
}
''');

    await assertHasFix('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    if (other is! Person) return false;
    final toCompare = other;
    return toCompare.name == name;
  }
}
''',
        errorFilter: (error) =>
            error.errorCode == StaticWarningCode.DEAD_NULL_AWARE_EXPRESSION);
  }

  /// todo(pq): implement or remove the lint (see: https://github.com/dart-lang/linter/issues/2864)
  @FailingTest(reason: 'Fix unimplemented')
  Future<void> test_ifStatement() async {
    await resolveTestCode('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    if (other == null) return false;
    return other is Person &&
          name == other.name;
  }
}
''');
    await assertHasFix('''
class Person {
  final String name = '';

  @override
  operator ==(Object other) {
    return other is Person &&
          name == other.name;
  }
}
''',
        errorFilter: (error) =>
            error.errorCode == HintCode.UNNECESSARY_NULL_COMPARISON_FALSE);
  }
}
