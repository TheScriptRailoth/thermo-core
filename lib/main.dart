import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
void main() => runApp(const MyApp());
GlobalKey<_RankineCycleCanvasState> rankineCanvasKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  String? _selectedComponentId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ComponentSidebar(selectedComponentId: _selectedComponentId),
          SizedBox(width: 20),
          Expanded(
            child: RankineCycleCanvas(
              onComponentSelected: (id) {
                setState(() {
                  _selectedComponentId = id;
                });
              },
            ),
          ),
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

    const double gridCellSize = 20;
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
  final Function(ComponentModel) onSelect;
  final bool isSelected;

  const ComponentWidget({
    Key? key,
    required this.component,
    required this.onSelect,
    this.isSelected=false,
  }) : super(key: key);

  @override
  _ComponentWidgetState createState() => _ComponentWidgetState();
}
class _ComponentWidgetState extends State<ComponentWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Calculate the positions of connection points relative to the component's position
    var connectionPoints = widget.component.connectionPoints;

    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelect(widget.component),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: _isHovered || widget.isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: SvgPicture.asset(
                      widget.component.type,
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              ...connectionPoints.keys.map((key) {
                Offset point = connectionPoints[key]!;
                // Make sure the positioning logic here correctly places the connection points
                // relative to the component's position on the canvas
                return Positioned(
                  left: point.dx,
                  top: point.dy,
                  child: Container(
                    width: 10, // Connection point size
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red, // Bright color for visibility
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}


class RankineCycleCanvas extends StatefulWidget {
  final Function(String?)? onComponentSelected;
  RankineCycleCanvas({Key? key, this.onComponentSelected}) : super(key: key);
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

  ComponentModel ?selectedComponent;

  void _selectComponent(ComponentModel component) {
    setState(() {
      // Deselect all components
      for (var comp in placedComponents) {
        comp.isSelected = false;
      }
      // Select the tapped component
      component.isSelected = true;
      selectedComponent = component; // This is optional depending on your implementation
      print('Selected component: ${component.id}');
      // selectedComponentId = component.id;
    });
    widget.onComponentSelected?.call(component.id);
  }

  void startConnection(ComponentModel component, String connectionPointKey) {
    final Offset startPoint = component.connectionPoints[connectionPointKey]!;
    setState(() {
      tempConnectionStart = startPoint;
      tempConnectionEnd = startPoint;
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
      onTap: (){
        if(selectedComponent!=null){
          setState(() {
            for(var comp in placedComponents){
              comp.isSelected=false;
              widget.onComponentSelected?.call(null);
            }
          });
        }
      },
      onPanUpdate: (details) {
        lastDragPosition = details.localPosition;
        updateTemporaryConnection(details.localPosition);
      },
      onPanEnd: (details) {
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
              // In your RankineCycleCanvas widget, inside the onAcceptWithDetails method
              onAcceptWithDetails: (details) {
                final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                final Offset localOffset = renderBox.globalToLocal(details.offset);
                setState(() {
                  ComponentModel component = details.data..position = localOffset;
                  component.updateConnectionPoints(); // Recalculate connection points based on new position
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
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectComponent(component);
                            });
                          },
                          child: Draggable<ComponentModel>(
                            data: component,
                            feedback: Material(
                              elevation: 4.0,
                              child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,),
                            ),
                            // Inside the onDragEnd or similar method
                            onDragEnd: (dragDetails) {
                              final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                              final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);

                              setState(() {
                                component.position = Offset(
                                  max(0, localOffsetCanvas.dx - (50 / 2)), // Adjust based on component's width for centering
                                  max(0, localOffsetCanvas.dy - (50/ 2)), // Adjust based on component's height for centering
                                );
                                component.updateConnectionPoints(); // Recalculate connection points based on new position
                              });
                            },
                            child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,),
                          ),
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
}

class ComponentSidebar extends StatelessWidget {
  final List<String> components = [
    'lib/presentation/assets/turbine_icon.svg',
    'lib/presentation/assets/boiler_icon.svg',
    'lib/presentation/assets/precipitator_icon.svg',
    'lib/presentation/assets/water_pump_icon.svg',
  ];
  final List<String> componentsTitle = ['Turbine', "Boiler", "Precipitator", "Water Pump"];
  final String? selectedComponentId;

  ComponentSidebar({Key? key, this.selectedComponentId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    void doNothing(ComponentModel component){}
    return Container(
      width: 300,
      color: Colors.grey[200],
      child: Column(
        children: [
          Container(
            height: 30,
            width: 300,
            color: Colors.grey,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 5,),
                Text("Devices", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.left,),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Flexible(
            child: GridView.builder(
              // The number of items in your grid
              itemCount: components.length,
              // Controls the layout of tiles in a grid
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 1, // Spacing between columns
                mainAxisSpacing: 10, // Spacing between rows
                childAspectRatio: 1.0, // Aspect ratio of the tiles
              ),
              itemBuilder: (context, index) {
                return Draggable<ComponentModel>(
                  data: ComponentModel(
                    id: UniqueKey().toString(),
                    type: components[index],
                    position: Offset.zero,
                  ),
                  feedback: Material(
                    child: ComponentWidget(
                      component: ComponentModel(
                        id: 'feedback-${components[index]}',
                        type: components[index],
                        position: Offset.zero,
                      ),
                      onSelect: doNothing,
                    ),
                    elevation: 4.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(components[index], width: 100, height: 100),
                        Text(componentsTitle[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20,),
          Container(
            color: Colors.greenAccent,
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Device Name : "),
                      Text(selectedComponentId != null ? selectedComponentId! : "None selected"),
                    ],
                  )
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}

class ComponentModel {
  final String id;
  final String type;
  Offset position;
  Map<String, Offset> connectionPoints;
  bool isSelected = false;

  ComponentModel({
    required this.id,
    required this.type,
    required this.position,
  }) : connectionPoints = {} {
    updateConnectionPoints();
  }

  void updateConnectionPoints() {
    // Assuming the component is 50px wide and the desired offset for connection points is directly on its edges
    connectionPoints = {
      'left': Offset(-10, 20), // 25 is half the height, making it vertically centered on the left
      'right': Offset(50, 20), // 50 is the width of the component, making it right-edge centered
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


