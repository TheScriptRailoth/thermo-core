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

class ComponentWidget extends StatefulWidget {
  final ComponentModel component;

  const ComponentWidget({Key? key, required this.component}) : super(key: key);

  @override
  _ComponentWidgetState createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Explicitly declare boxShadow as List<BoxShadow>
    final List<BoxShadow> boxShadow = _isHovered
        ? [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        spreadRadius: 1,
        blurRadius: 5,
        offset: Offset(0, 3), // Changes position of shadow
      ),
    ]
        : [];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Transform.scale(
        scale: _isHovered ? 1.05 : 1.0, // Slightly scale up on hover
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
            boxShadow: boxShadow, // Apply the explicitly typed list here
          ),
          child: Center(
            child: SvgPicture.asset(widget.component.type, width: 30, height: 30),
          ),
        ),
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

class ConnectionPointButton extends StatefulWidget {
  final IconData iconData;
  final VoidCallback onTap;

  const ConnectionPointButton({
    Key? key,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  @override
  _ConnectionPointButtonState createState() => _ConnectionPointButtonState();
}

class _ConnectionPointButtonState extends State<ConnectionPointButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovering ? Colors.green : Colors.blue, // Change color on hover
            shape: BoxShape.circle,
            boxShadow: _isHovering
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Icon(
            widget.iconData,
            size: 20,
            color: Colors.white,
          ),
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
