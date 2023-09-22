import 'package:flutter/material.dart';

MaterialApp createWidgetInASkeleton(Widget widget) {
  return MaterialApp(home: Scaffold(body: Center(child: widget,),));
}
