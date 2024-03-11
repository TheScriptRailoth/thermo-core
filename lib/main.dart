import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() => runApp(MyApp());
GlobalKey<_RankineCycleCanvasState> rankineCanvasKey = GlobalKey();

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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(component.type, width: 50, height: 50, fit: BoxFit.fill,),
          ),
        ),
        // Pass `context` to `_buildConnectionPoints`
        ..._buildConnectionPoints(context),
      ],
    );
  }

  List<Widget> _buildConnectionPoints(BuildContext context) {
    return component.connectionPoints.keys.map((key) {
      return Positioned(
        left: component.connectionPoints[key]!.dx - 10,
        top: component.connectionPoints[key]!.dy - 10,
        child: GestureDetector(
          onTap: () {
            // Call `startConnection` with the correct parameters
            rankineCanvasKey.currentState?.startConnection(component, key);
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
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
  RankineCycleCanvas({Key? key}) : super(key: rankineCanvasKey);
  @override

  _RankineCycleCanvasState createState() => _RankineCycleCanvasState();
}

class _RankineCycleCanvasState extends State<RankineCycleCanvas> {
  List<ComponentModel> placedComponents = [];
  List<Connection> connections = [];
  ComponentModel? currentStartComponent;
  Offset? temporaryEndPosition;

  Offset? tempConnectionStart;
  Offset? tempConnectionEnd;
  Offset? lastDragPosition;

  void startConnection(ComponentModel component, String connectionPointKey) {
    final Offset startPoint = component.connectionPoints[connectionPointKey]!;
    setState(() {
      tempConnectionStart = startPoint;
      tempConnectionEnd = startPoint; // Initialize to the start position
    });
  }

  void updateTemporaryConnection(Offset newPosition) {
    setState(() {
      tempConnectionEnd = newPosition;
    });
  }

  void completeConnection(Offset end, String startComponentId, String endComponentId) {
    setState(() {
      connections.add(Connection(
          startComponentId: startComponentId,
          endComponentId: endComponentId,
          startPosition: tempConnectionStart!,
          endPosition: end));
      tempConnectionStart = null;
      tempConnectionEnd = null;
    });
  }

  final GlobalKey _canvasKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        lastDragPosition = details.localPosition;
        updateTemporaryConnection(details.localPosition);
      },
      onPanEnd: (details) {
        // Here, implement logic to determine the endComponentId based on the location
        if (lastDragPosition != null) {
          completeConnection(lastDragPosition!, "startComponentId", "endComponentId");
          lastDragPosition = null; // Reset the position
        }
      },
      child: CustomPaint(
          painter: GridPainter(),
          foregroundPainter: ConnectionLinePainter(connections, tempConnectionStart, tempConnectionEnd),
          child: DragTarget<ComponentModel>(
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
          )
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return DragTarget<ComponentModel>(
  //     onWillAccept: (data) => true,
  //     onAcceptWithDetails: (details) {
  //       final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
  //       final Offset localOffset = renderBox.globalToLocal(details.offset);
  //
  //       setState(() {
  //         ComponentModel component = details.data..position = localOffset - const Offset(200, 0);
  //         component.updateConnectionPoints();
  //         placedComponents.add(component);
  //       });
  //     },
  //     builder: (context, candidateData, rejectedData) {
  //       return Container(
  //         key: _canvasKey,
  //         color: Colors.white,
  //         child: CustomPaint(
  //           painter: GridPainter(),
  //           child: Stack(
  //             children: placedComponents.map((component) {
  //               return Positioned(
  //                 left: component.position.dx,
  //                 top: component.position.dy,
  //                 child: Draggable<ComponentModel>(
  //                   data: component,
  //                   feedback: Material(
  //                     elevation: 4.0,
  //                     child: ComponentWidget(component: component),
  //                   ),
  //                   childWhenDragging: Opacity(
  //                     opacity: 0.5,
  //                     child: ComponentWidget(component: component),
  //                   ),
  //                   onDragEnd: (dragDetails) {
  //                     final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
  //                     final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
  //
  //                     setState(() {
  //                       component.position = Offset(
  //                         max(0, localOffsetCanvas.dx),
  //                         max(0, localOffsetCanvas.dy),
  //                       );
  //                       component.updateConnectionPoints();
  //                     });
  //                   },
  //                   child: ComponentWidget(component: component),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
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
                  Text(componentsTitle[index], style: const TextStyle(fontWeight: FontWeight.bold)),
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
      'left': Offset(0, 30),
      'right': Offset(60, 30),
      // 'top': Offset(30, 0),
      // 'bottom': Offset(30, 60),
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
  final List<Connection> connections;
  final Offset? tempStart;
  final Offset? tempEnd;

  ConnectionLinePainter(this.connections, this.tempStart, this.tempEnd);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var connection in connections) {
      canvas.drawLine(connection.startPosition, connection.endPosition, paint);
    }

    if (tempStart != null && tempEnd != null) {
      canvas.drawLine(tempStart!, tempEnd!, paint..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Connection {
  final String startComponentId;
  final String endComponentId;
  final Offset startPosition;
  final Offset endPosition;

  Connection({required this.startComponentId, required this.endComponentId, required this.startPosition, required this.endPosition});
}

//
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: InteractiveCanvas(),
//         ),
//       ),
//     );
//   }
// }
//
// class Node {
//   Offset position;
//
//   Node(this.position);
// }
//
// class Connection {
//   Node start;
//   Node end;
//
//   Connection(this.start, this.end);
// }
//
// class InteractiveCanvas extends StatefulWidget {
//   @override
//   _InteractiveCanvasState createState() => _InteractiveCanvasState();
// }
//
// class _InteractiveCanvasState extends State<InteractiveCanvas> {
//   List<Node> nodes = [];
//   List<Connection> connections = [];
//   Node? tempStartNode; // Temporary start node for a connection being drawn
//   Offset? lastPosition; // Tracks the last known position during a pan
//
//   void _handleTapUp(TapUpDetails details) {
//     setState(() {
//       nodes.add(Node(details.localPosition));
//     });
//   }
//
//   void _handlePanStart(DragStartDetails details) {
//     final startNode = _findNodeNearPoint(details.localPosition);
//     if (startNode != null) {
//       tempStartNode = startNode;
//     }
//   }
//
//   void _handlePanUpdate(DragUpdateDetails details) {
//     // Update the last known position
//     setState(() {
//       lastPosition = details.localPosition;
//     });
//   }
//
//   void _handlePanEnd(DragEndDetails details) {
//     if (tempStartNode != null && lastPosition != null) {
//       final endNode = _findNodeNearPoint(lastPosition!);
//       if (endNode != null && endNode != tempStartNode) {
//         setState(() {
//           connections.add(Connection(tempStartNode!, endNode));
//         });
//       }
//     }
//     tempStartNode = null; // Reset temporary start node
//     lastPosition = null; // Reset the last known position
//   }
//
//   Node? _findNodeNearPoint(Offset point) {
//     for (var node in nodes) {
//       if ((node.position - point).distance < 20.0) { // 20.0 is the tolerance radius
//         return node;
//       }
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapUp: _handleTapUp,
//       onPanStart: _handlePanStart,
//       onPanUpdate: _handlePanUpdate,
//       onPanEnd: _handlePanEnd,
//       child: CustomPaint(
//         size: Size.infinite,
//         painter: CanvasPainter(nodes, connections),
//       ),
//     );
//   }
// }
//
// class CanvasPainter extends CustomPainter {
//   final List<Node> nodes;
//   final List<Connection> connections;
//
//   CanvasPainter(this.nodes, this.connections);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke;
//
//     // Draw connections
//     for (var connection in connections) {
//       canvas.drawLine(connection.start.position, connection.end.position, paint);
//     }
//
//     // Draw nodes
//     for (var node in nodes) {
//       canvas.drawCircle(node.position, 10.0, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true; // In a real app, this should be optimized to repaint only when necessary.
//   }
// }
