import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'skeleton_for_widget_testing.dart';

main() {
  test("test creating a skeleton for widget testing", () {
    Text text = const Text("a text");
    MaterialApp skeletonWithAWidget = createWidgetInASkeleton(text);
    Scaffold? scaffold = skeletonWithAWidget.home as Scaffold?;
    Center? body = scaffold!.body as Center;
    Widget? child = body.child;
    expect(child, text);
  });
}
