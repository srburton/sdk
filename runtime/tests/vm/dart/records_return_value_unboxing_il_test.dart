// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Verifies that compiler can unbox records in return values.

// SharedOptions=--enable-experiment=records

import 'package:vm/testing/il_matchers.dart';

@pragma('vm:never-inline')
@pragma('vm:testing:print-flow-graph')
(int, bool) getRecord1(int x, bool y) => (x, y);

@pragma('vm:never-inline')
@pragma('vm:testing:print-flow-graph')
({String foo, int bar}) getRecord2(String foo, int bar) => (foo: foo, bar: bar);

abstract class A {
  (int, {double y}) get record3;
}

class B implements A {
  final int x;
  final double y;
  B(this.x, this.y);

  @pragma('vm:never-inline')
  @pragma('vm:testing:print-flow-graph')
  (int, {double y}) get record3 => (x, y: y);
}

class C extends A {
  (int, {double y}) get record3 => (1, y: 2);
}

@pragma('vm:never-inline')
@pragma('vm:testing:print-flow-graph')
void test(int x, bool z, String foo, int bar, A obj1, A obj2) {
  final r1 = getRecord1(x, z);
  print(r1.$0);
  print(r1.$1);
  final r2 = getRecord2(foo, bar);
  print(r2.foo);
  print(r2.bar);
  final r3 = obj1.record3;
  print(r3.$0);
  print(r3.y);
  final r4 = obj2.record3;
  print(r4);
}

void matchIL$getRecord1(FlowGraph graph) {
  graph.match([
    match.block('Graph'),
    match.block('Function', [
      'x' << match.Parameter(index: 0),
      'y' << match.Parameter(index: 1),
      'x_boxed' << match.BoxInt64('x'),
      'pair' << match.MakePair('x_boxed', 'y'),
      match.Return('pair'),
    ]),
  ]);
}

void matchIL$getRecord2(FlowGraph graph) {
  graph.match([
    match.block('Graph'),
    match.block('Function', [
      'foo' << match.Parameter(index: 0),
      'bar' << match.Parameter(index: 1),
      'bar_boxed' << match.BoxInt64('bar'),
      'pair' << match.MakePair('bar_boxed', 'foo'),
      match.Return('pair'),
    ]),
  ]);
}

void matchIL$record3(FlowGraph graph) {
  graph.match([
    match.block('Graph'),
    match.block('Function', [
      'this' << match.Parameter(index: 0),
      'x' << match.LoadField('this', slot: 'x'),
      'y' << match.LoadField('this', slot: 'y'),
      'x_boxed' << match.BoxInt64('x'),
      'y_boxed' << match.Box('y'),
      'pair' << match.MakePair('x_boxed', 'y_boxed'),
      match.Return('pair'),
    ]),
  ]);
}

void matchIL$test(FlowGraph graph) {
  graph.match([
    match.block('Graph'),
    match.block('Function', [
      'x' << match.Parameter(index: 0),
      'z' << match.Parameter(index: 1),
      'foo' << match.Parameter(index: 2),
      'bar' << match.Parameter(index: 3),
      'obj1' << match.Parameter(index: 4),
      'obj2' << match.Parameter(index: 5),
      match.CheckStackOverflow(),

      'x_unboxed' << match.UnboxInt64('x'),
      match.PushArgument('x_unboxed'),
      match.PushArgument('z'),
      'r1' << match.StaticCall(),
      'r1_0' << match.ExtractNthOutput('r1', index: 0),
      'r1_1' << match.ExtractNthOutput('r1', index: 1),
      match.PushArgument('r1_0'),
      match.StaticCall(),
      match.PushArgument('r1_1'),
      match.StaticCall(),

      match.PushArgument('foo'),
      match.PushArgument('bar'),
      'r2' << match.StaticCall(),
      'r2_bar' << match.ExtractNthOutput('r2', index: 0),
      'r2_foo' << match.ExtractNthOutput('r2', index: 1),
      match.PushArgument('r2_foo'),
      match.StaticCall(),
      match.PushArgument('r2_bar'),
      match.StaticCall(),

      match.PushArgument('obj1'),
      'r3' << match.StaticCall(),
      'r3_0' << match.ExtractNthOutput('r3', index: 0),
      'r3_y' << match.ExtractNthOutput('r3', index: 1),
      match.PushArgument('r3_0'),
      match.StaticCall(),
      match.PushArgument('r3_y'),
      match.StaticCall(),

      'obj2_cid' << match.LoadClassId('obj2'),
      match.PushArgument('obj2'),
      'r4' << match.DispatchTableCall('obj2_cid'),
      'r4_0' << match.ExtractNthOutput('r4', index: 0),
      'r4_y' << match.ExtractNthOutput('r4', index: 1),
      'r4_boxed' << match.AllocateSmallRecord('r4_0', 'r4_y'),
      match.PushArgument('r4_boxed'),
      match.StaticCall(),

      match.Return(),
    ]),
  ]);
}

void main() {
  // Make sure all parameters are non-constant
  // and obj1 has a known type for devirtualization.
  test(int.parse('5')!,
    int.parse('3') == 4,
    'foo' + 3.toString(),
    int.parse('7')!,
    B(int.parse('8')!, double.parse('9')!),
    int.parse('10') == 11 ? B(1, 2) : C());
}
