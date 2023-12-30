import 'package:flutter/services.dart';

const passwordMinimumLength = 6;

final FilteringTextInputFormatter noWhiteSpaceInputFormatter =
    FilteringTextInputFormatter.deny(RegExp(r'\s'));
