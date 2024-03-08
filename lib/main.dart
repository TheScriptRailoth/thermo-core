import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: HomeScreen()),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ComponentSidebar(),
          SizedBox(width: 20),
          Expanded(child: RankineCycleCanvas()),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeCap = StrokeCap.round;

    const double gridCellSize = 40;
    const double dotRadius = 2;

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
  final ComponentModel component;

  ComponentWidget({Key? key, required this.component}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(component.type, width: 30, height: 30),
          ),
        ),
        // Pass `context` to `_buildConnectionPoints`
        ..._buildConnectionPoints(context),
      ],
    );
  }

  List<Widget> _buildConnectionPoints(BuildContext context) {
    return component.connectionPoints.entries.map((entry) {
      Offset pointPosition = entry.value; // Assuming this gives the global position

      return Positioned(
        left: pointPosition.dx - 10, // Adjust based on actual layout
        top: pointPosition.dy - 10,
        child: ConnectionPointButton(
          iconData: Icons.add, // or any other icon
          onTap: () {
            // Handle tap: Start connection drawing process here
            print("Tapped on connection point at $pointPosition");
            // You might want to set some state indicating a connection is being started
          },
        ),
      );
    }).toList();
  }


  void _onConnectionPointTap(BuildContext context, String pointKey, ComponentModel component) {
    // Implement your logic here, like showing a dialog or another UI component
    // This method might trigger a UI that allows connecting this component to another
  }
}


class RankineCycleCanvas extends StatefulWidget {
  @override
  _RankineCycleCanvasState createState() => _RankineCycleCanvasState();
}

class _RankineCycleCanvasState extends State<RankineCycleCanvas> {
  List<ComponentModel> placedComponents = [];

  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DragTarget<ComponentModel>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
        final Offset localOffset = renderBox.globalToLocal(details.offset);

        setState(() {
          ComponentModel component = details.data..position = localOffset - const Offset(200, 0);
          component.updateConnectionPoints();
          placedComponents.add(component);
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
                      child: ComponentWidget(component: component),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: ComponentWidget(component: component),
                    ),
                    onDragEnd: (dragDetails) {
                      final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                      final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);

                      setState(() {
                        component.position = Offset(
                          max(0, localOffsetCanvas.dx),
                          max(0, localOffsetCanvas.dy),
                        );
                        component.updateConnectionPoints();
                      });
                    },
                    child: ComponentWidget(component: component),
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

class ComponentSidebar extends StatelessWidget {
  final List<String> components = [
    'lib/presentation/assets/turbine_icon.svg',
    'lib/presentation/assets/boiler_icon.svg',
    'lib/presentation/assets/precipitator_icon.svg',
    'lib/presentation/assets/water_pump_icon.svg',
  ];
  final List<String> componentsTitle = ['Turbine', "Boiler", "Precipitator", "Water Pump"];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: components.length,
        itemBuilder: (context, index) {
          return Draggable<ComponentModel>(
            data: ComponentModel(
              id: UniqueKey().toString(),
              type: components[index
              ],
              position: Offset.zero,
            ),
            feedback: Material(
              child: ComponentWidget(
                component: ComponentModel(
                  id: 'feedback-${components[index]}',
                  type: components[index],
                  position: Offset.zero,
                ),
              ),
              elevation: 4.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SvgPicture.asset(components[index], width: 48, height: 48),
                  Text(componentsTitle[index], style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
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
  }) : connectionPoints = {} {
    updateConnectionPoints();
  }

  void updateConnectionPoints() {
    connectionPoints = {
      'left': Offset(-5, 25),
      'right': Offset(55, 25),
      'top': Offset(25, -5),
      'bottom': Offset(25, 55),
    };
  }
}

class ConnectionPointButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap; // Adjust if you need to pass more information on tap
  final bool isHovered;

  const ConnectionPointButton({
    Key? key,
    required this.iconData,
    required this.onTap,
    this.isHovered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Icon(
          iconData,
          size: 20,
          color: isHovered ? Colors.green : Colors.blue,
        ),
      ),
    );
  }
}


class ConnectionLinePainter extends CustomPainter {
  List<Connection> connections;

  ConnectionLinePainter(this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var connection in connections) {
      canvas.drawLine(connection.start, connection.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Connection {
  Offset start;
  Offset end;

  Connection(this.start, this.end);
}
