import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            ComponentSidebar(),
            SizedBox(width: 20),
            Expanded(child: RankineCycleCanvas()),
          ],
        ),
      ),
    );
  }
}

class ComponentModel {
  final String id;
  final String type;
  Offset position;
  Map<String, Offset> connectionPoints;

  ComponentModel({
    required this.id,
    required this.type,
    required this.position,
  }) : connectionPoints = {
    'left': Offset(position.dx, position.dy + 25), // Assuming the component height is 50
    'right': Offset(position.dx + 50, position.dy + 25), // Assuming the component width is 50
    'top': Offset(position.dx + 25, position.dy),
    'bottom': Offset(position.dx + 25, position.dy + 50),
  };
}

class ComponentSidebar extends StatelessWidget {
  final List<String> components = ['lib/presentation/assets/turbine_icon.svg', 'lib/presentation/assets/boiler_icon.svg', 'lib/presentation/assets/precipitator_icon.svg', 'lib/presentation/assets/water_pump_icon.svg'];
  final List<String> componentsTitle = ['Turbine', "Boiler", "Precipitator", "Water Pump" ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: components.length,
        itemBuilder: (context, index) {
          return Draggable<ComponentModel>(
            // Here we create a new ComponentModel with a unique ID for each draggable component
            data: ComponentModel(
              id: UniqueKey().toString(), // Generate a unique ID
              type: components[index],
              position: Offset.zero,
            ),
            feedback: Material(
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue,
                child: SvgPicture.asset(components[index]),
              ),
              elevation: 4.0,
            ),
            child: Container(
              child: Column(
                children: [
                  Container(
                    child: SvgPicture.asset(components[index]),
                  ),
                  Text(componentsTitle[index], style: const TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class RankineCycleCanvas extends StatefulWidget {
  @override
  _RankineCycleCanvasState createState() => _RankineCycleCanvasState();
}

class _RankineCycleCanvasState extends State<RankineCycleCanvas> {
  List<ComponentModel> placedComponents = [];
  List<Map<String, dynamic>> connections = [];
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DragTarget<ComponentModel>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
        final Offset localOffset = renderBox.globalToLocal(details.offset);

        setState(() {
          // Here we adjust the localOffset by taking into account the initial drag position within the component
          // Assuming sidebar width is 200, we need to subtract this from the dropped position's X coordinate
          details.data.position = localOffset - const Offset(200, 0);
          placedComponents.add(details.data);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          key: _canvasKey,
          color: Colors.white,
          child: CustomPaint(
            painter: GridPainter(),
            child: Stack(
              children: placedComponents.map((component) {
                return Positioned(
                  left: component.position.dx,
                  top: component.position.dy,
                  child: Draggable<ComponentModel>(
                    data: component,
                    feedback: Material(
                      elevation: 4.0,
                      child: ComponentWidget(type: component.type),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: ComponentWidget(type: component.type),
                    ),
                    onDragEnd: (dragDetails) {
                      // Instead of subtracting the sidebar width, directly use the converted local offset
                      final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                      final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);

                      setState(() {
                        // Directly set the component's new position based on the local offset within the canvas
                        component.position = Offset(
                          max(0, localOffsetCanvas.dx),
                          max(0, localOffsetCanvas.dy),
                        );
                      });
                    },
                    child: ComponentWidget(type: component.type),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}



class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5) // Adjust the color and opacity as needed
      ..strokeCap = StrokeCap.round;

    const double gridCellSize = 40; // Size of each grid cell
    const double dotRadius = 2; // Radius of each dot

    // Draw dots
    for (double x = 0; x < size.width; x += gridCellSize) {
      for (double y = 0; y < size.height; y += gridCellSize) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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




