import 'package:flutter/services.dart';

const passwordMinimumLength = 8;

final FilteringTextInputFormatter noWhiteSpaceInputFormatter =
    FilteringTextInputFormatter.deny(RegExp(r'\s'));
