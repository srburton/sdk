// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SwitchStatementResolutionTest);
    defineReflectiveTests(SwitchStatementResolutionTest_Language218);
  });
}

@reflectiveTest
class SwitchStatementResolutionTest extends PubPackageResolutionTest {
  test_default() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case 0?:
      break;
    default:
      break;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: PostfixPattern
          operand: ConstantPattern
            expression: IntegerLiteral
              literal: 0
              staticType: int
          operator: ?
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
    SwitchDefault
      keyword: default
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }

  test_mergeCases() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case 0?:
    case 1?:
      break;
    case 2?:
      break;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: PostfixPattern
          operand: ConstantPattern
            expression: IntegerLiteral
              literal: 0
              staticType: int
          operator: ?
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: PostfixPattern
          operand: ConstantPattern
            expression: IntegerLiteral
              literal: 1
              staticType: int
          operator: ?
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: PostfixPattern
          operand: ConstantPattern
            expression: IntegerLiteral
              literal: 2
              staticType: int
          operator: ?
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }

  test_rewrite_pattern() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case const A():
      break;
  }
}

class A {
  const A();
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ConstantPattern
          const: const
          expression: InstanceCreationExpression
            constructorName: ConstructorName
              type: NamedType
                name: SimpleIdentifier
                  token: A
                  staticElement: self::@class::A
                  staticType: null
                type: A
              staticElement: self::@class::A::@constructor::new
            argumentList: ArgumentList
              leftParenthesis: (
              rightParenthesis: )
            staticType: A
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }

  test_rewrite_whenClause() async {
    await assertNoErrorsInCode(r'''
void f(Object? x, bool Function() a) {
  switch (x) {
    case 0 when a():
      break;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ConstantPattern
          expression: IntegerLiteral
            literal: 0
            staticType: int
        whenClause: WhenClause
          whenKeyword: when
          expression: FunctionExpressionInvocation
            function: SimpleIdentifier
              token: a
              staticElement: self::@function::f::@parameter::a
              staticType: bool Function()
            argumentList: ArgumentList
              leftParenthesis: (
              rightParenthesis: )
            staticElement: <null>
            staticInvokeType: bool Function()
            staticType: bool
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareBoth_consistent() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case int a when a < 0:
    case int a when a > 0:
      a;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@48
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@48
              staticType: int
            operator: <
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::<::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::<
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@75
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@75
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: a[a@48, a@75]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareBoth_consistent_final() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case final int a when a < 0:
    case final int a when a > 0:
      a;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          keyword: final
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: isFinal a@54
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@54
              staticType: int
            operator: <
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::<::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::<
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          keyword: final
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: isFinal a@87
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@87
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: final a[a@54, a@87]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareBoth_notConsistent_differentFinality() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case final int a when a < 0:
    case int a when a > 0:
      a;
  }
}
''', [
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          101,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          keyword: final
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: isFinal a@54
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@54
              staticType: int
            operator: <
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::<::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::<
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@81
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@81
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@54, a@81]
            staticType: dynamic
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareBoth_notConsistent_differentFinalityTypes() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case final int a when a < 0:
    case num a when a > 0:
      a;
  }
}
''', [
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          101,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          keyword: final
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: isFinal a@54
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@54
              staticType: int
            operator: <
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::<::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::<
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: num
              staticElement: dart:core::@class::num
              staticType: null
            type: num
          name: a
          declaredElement: a@81
            type: num
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@81
              staticType: num
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@54, a@81]
            staticType: dynamic
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareBoth_notConsistent_differentTypes() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case int a when a < 0:
    case num a when a > 0:
      a;
  }
}
''', [
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          95,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@48
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@48
              staticType: int
            operator: <
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::<::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::<
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: num
              staticElement: dart:core::@class::num
              staticType: null
            type: num
          name: a
          declaredElement: a@75
            type: num
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@75
              staticType: num
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@48, a@75]
            staticType: dynamic
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareFirst() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case 0:
    case int a when a > 0:
      a;
  }
}
''', [
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          80,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ConstantPattern
          expression: IntegerLiteral
            literal: 0
            staticType: int
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@60
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@60
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@60]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_declareSecond() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case int a when a > 0:
    case 0:
      a;
  }
}
''', [
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          80,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@48
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@48
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ConstantPattern
          expression: IntegerLiteral
            literal: 0
            staticType: int
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@48]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_hasDefault() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case int a when a > 0:
    default:
      a;
  }
}
''', [
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          81,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@48
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@48
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
    SwitchDefault
      keyword: default
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@48]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_joinedCase_hasLabel() async {
    await assertErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    myLabel:
    case int a when a > 0:
      a;
  }
}
''', [
      error(HintCode.UNUSED_LABEL, 39, 8),
      error(
          CompileTimeErrorCode.INCONSISTENT_PATTERN_VARIABLE_SHARED_CASE_SCOPE,
          81,
          1),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      labels
        Label
          label: SimpleIdentifier
            token: myLabel
            staticElement: myLabel@39
            staticType: null
          colon: :
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@61
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@61
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: notConsistent a[a@61]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_logicalOr() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case <int>[var a || var a]:
      a;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ListPattern
          typeArguments: TypeArgumentList
            leftBracket: <
            arguments
              NamedType
                name: SimpleIdentifier
                  token: int
                  staticElement: dart:core::@class::int
                  staticType: null
                type: int
            rightBracket: >
          leftBracket: [
          elements
            LogicalOrPattern
              leftOperand: DeclaredVariablePattern
                keyword: var
                name: a
                declaredElement: hasImplicitType a@54
                  type: int
              operator: ||
              rightOperand: DeclaredVariablePattern
                keyword: var
                name: a
                declaredElement: hasImplicitType a@63
                  type: int
          rightBracket: ]
          requiredType: List<int>
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: a[a@54, a@63]
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_scope() async {
    await assertErrorsInCode(r'''
const a = 0;
void f(Object? x) {
  switch (x) {
    case [int a, == a] when a > 0:
      a;
  }
}
''', [
      error(CompileTimeErrorCode.NON_CONSTANT_RELATIONAL_PATTERN_EXPRESSION, 68,
          1),
      error(CompileTimeErrorCode.REFERENCED_BEFORE_DECLARATION, 68, 1,
          contextMessages: [message('/home/test/lib/test.dart', 62, 1)]),
    ]);

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ListPattern
          leftBracket: [
          elements
            DeclaredVariablePattern
              type: NamedType
                name: SimpleIdentifier
                  token: int
                  staticElement: dart:core::@class::int
                  staticType: null
                type: int
              name: a
              declaredElement: a@62
                type: int
            RelationalPattern
              operator: ==
              operand: SimpleIdentifier
                token: a
                staticElement: a@62
                staticType: int
              element: dart:core::@class::Object::@method::==
          rightBracket: ]
          requiredType: List<Object?>
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@62
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: a@62
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_variables_singleCase() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case int a when a > 0:
      a;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: DeclaredVariablePattern
          type: NamedType
            name: SimpleIdentifier
              token: int
              staticElement: dart:core::@class::int
              staticType: null
            type: int
          name: a
          declaredElement: a@48
            type: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BinaryExpression
            leftOperand: SimpleIdentifier
              token: a
              staticElement: a@48
              staticType: int
            operator: >
            rightOperand: IntegerLiteral
              literal: 0
              parameter: dart:core::@class::num::@method::>::@parameter::other
              staticType: int
            staticElement: dart:core::@class::num::@method::>
            staticInvokeType: bool Function(num)
            staticType: bool
      colon: :
      statements
        ExpressionStatement
          expression: SimpleIdentifier
            token: a
            staticElement: a@48
            staticType: int
          semicolon: ;
  rightBracket: }
''');
  }

  test_whenClause() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case 0 when true:
      break;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchPatternCase
      keyword: case
      guardedPattern: GuardedPattern
        pattern: ConstantPattern
          expression: IntegerLiteral
            literal: 0
            staticType: int
        whenClause: WhenClause
          whenKeyword: when
          expression: BooleanLiteral
            literal: true
            staticType: bool
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }
}

@reflectiveTest
class SwitchStatementResolutionTest_Language218 extends PubPackageResolutionTest
    with WithLanguage218Mixin {
  test_default() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case 0:
      break;
    default:
      break;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchCase
      keyword: case
      expression: IntegerLiteral
        literal: 0
        staticType: int
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
    SwitchDefault
      keyword: default
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }

  test_mergeCases() async {
    await assertNoErrorsInCode(r'''
void f(Object? x) {
  switch (x) {
    case 0:
    case 1:
      break;
    case 2:
      break;
  }
}
''');

    final node = findNode.switchStatement('switch');
    assertResolvedNodeText(node, r'''
SwitchStatement
  switchKeyword: switch
  leftParenthesis: (
  expression: SimpleIdentifier
    token: x
    staticElement: self::@function::f::@parameter::x
    staticType: Object?
  rightParenthesis: )
  leftBracket: {
  members
    SwitchCase
      keyword: case
      expression: IntegerLiteral
        literal: 0
        staticType: int
      colon: :
    SwitchCase
      keyword: case
      expression: IntegerLiteral
        literal: 1
        staticType: int
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
    SwitchCase
      keyword: case
      expression: IntegerLiteral
        literal: 2
        staticType: int
      colon: :
      statements
        BreakStatement
          breakKeyword: break
          semicolon: ;
  rightBracket: }
''');
  }
}
