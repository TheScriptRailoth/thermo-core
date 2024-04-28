import 'package:flutter/cupertino.dart';

import '../../core/utils/arrow_painter.dart';

class LongArrowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(40, 20),
      painter: ArrowPainter(),
    );
  }
}