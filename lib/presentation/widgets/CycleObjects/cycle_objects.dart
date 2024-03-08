import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ComponentWidget extends StatelessWidget {
  final String type;

  const ComponentWidget({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Customize this widget based on the component type
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SvgPicture.asset(type),
      ),
    );
  }
}


