import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_testing_helper.dart';

main() {
  test("test creating a skeleton for widget testing", () {
    Text text = const Text("a text");
    MaterialApp skeletonWithAWidget = createWidgetInASkeleton(text);
    Scaffold? scaffold = skeletonWithAWidget.home as Scaffold?;
    Text? body = scaffold!.body as Text;
    expect(body, text);
  });
}
