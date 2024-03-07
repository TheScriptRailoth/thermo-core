import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CycleObjects/cycle_objects.dart';

class CanvasArea extends StatefulWidget {
  const CanvasArea({Key? key}) : super(key: key);

  @override
  _CanvasAreaState createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasArea> {
  List<ThermodynamicObject> droppedObjects = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            // Handle tap on canvas
            // For example, add a new object at the tapped position
            setState(() {
              droppedObjects.add(
                ThermodynamicObject(
                  name: 'Dropped Object',
                  color: Colors.green, // Change color as needed
                ),
              );
            });
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white, // Change canvas background color as needed
          ),
        ),
        // Render dropped objects on the canvas
        for (final object in droppedObjects)
          Positioned(
            left: object.isSelected ? 50.0 : 0.0,
            top: object.isSelected ? 50.0 : 0.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // Deselect all objects
                  droppedObjects.forEach((element) {
                    element.isSelected = false;
                  });
                  // Toggle the selected state of the tapped object
                  object.isSelected = true;
                });
              },
              child: Container(
                height: 50,
                width: 50,
                color: object.color,
              ),
            ),
          ),
      ],
    );
  }
}
