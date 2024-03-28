import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_svg/svg.dart';

import 'home_screen.dart';
class GridPainter extends CustomPainter {
  double gridCellSize = 20.0;
  @override

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeCap = StrokeCap.round;

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
  final Function(ComponentModel) onDelete;
  final bool isSelected;

  const ComponentWidget({
    Key? key,
    required this.component,
    required this.onSelect,
    this.isSelected=false,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ComponentWidgetState createState() => _ComponentWidgetState();
}
class _ComponentWidgetState extends State<ComponentWidget> {
  bool _isHoveredIcon = false;
  Map<String, bool> _hoveredConnectionPoints = {};

  @override
  Widget build(BuildContext context) {
    print("Connection Points : ${widget.component.connectionPoints}");
    final entries = <ContextMenuEntry>[
      MenuItem(
        label: 'Delete',
        icon: Icons.delete,
        onSelected: () {
          widget.onDelete(widget.component);
        },
      ),
    ];
    return ContextMenuRegion(
      contextMenu: ContextMenu(entries: entries),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 0.0,
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onSelect(widget.component),
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHoveredIcon = true),
                onExit: (_) => setState(() => _isHoveredIcon = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: _isHoveredIcon || widget.isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: SvgPicture.asset(
                        widget.component.imagePath,
                        width: 70,
                        height: 70,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildComponentVisualization(),
          ..._buildConnectionPoints(),
          // ...widget.component.connectionPoints.keys.map((key) {
          //   Offset point = widget.component.connectionPoints[key]!;
          //   return Positioned(
          //     left: point.dx,
          //     top: point.dy,
          //     child: InkWell(
          //       onTap: (){},
          //       child: MouseRegion(
          //         onEnter: (_)=>setState(() {
          //           _isHoveredNode=true;
          //         }),
          //         onExit: (_)=> setState(() {
          //           _isHoveredNode = false;
          //         }),
          //         child: Container(
          //           width: 12,
          //           height: 12,
          //           decoration: BoxDecoration(
          //               color: _isHoveredNode?Colors.green:Colors.red,
          //               shape: BoxShape.circle,
          //               border: Border.all(width: 1,color: _isHoveredNode?Colors.black:Colors.transparent)
          //           ),
          //         ),
          //       ),
          //     ),
          //   );
          // }).toList(),
        ],
      ),
    );
  }

  Widget _buildComponentVisualization() {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelect(widget.component),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHoveredIcon = true),
          onExit: (_) => setState(() => _isHoveredIcon = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: _isHoveredIcon || widget.isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: SvgPicture.asset(
                  widget.component.imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // List<Widget> _buildConnectionPoints() {
  //   return widget.component.connectionPoints.entries.map((entry) {
  //     final key = entry.key;
  //     final position = entry.value;
  //     final isHovered = _hoveredConnectionPoints[key] ?? false;
  //
  //     String imagePath1;
  //     if (key == 'left') {
  //       imagePath1 = 'lib/presentation/assets/inlet_icon.svg';
  //     } else {
  //       imagePath1 = 'lib/presentation/assets/outlet_icon.svg';
  //     }
  //     return Positioned(
  //       left: position.dx - 6,
  //       top: position.dy - 6,
  //       child: MouseRegion(
  //         onEnter: (_) => setState(() => _hoveredConnectionPoints[key] = true),
  //         onExit: (_) => setState(() => _hoveredConnectionPoints[key] = false),
  //         child: Container(
  //           width: 12,
  //           height: 12,
  //           decoration: BoxDecoration(
  //             color: isHovered ? Colors.green : Colors.red,
  //             shape: BoxShape.circle,
  //             border: Border.all(color: isHovered ? Colors.black : Colors.transparent),
  //           ),
  //         ),
  //       ),
  //     );
  //   }).toList();
  // }

  List<Widget> _buildConnectionPoints() {
    return widget.component.connectionPoints.entries.map((entry) {
      final key = entry.key;
      final position = entry.value;
      final isHovered = _hoveredConnectionPoints[key] ?? false;

      String svgAssetPath = key == 'inlet' ? 'lib/presentation/assets/inlet_icon.svg' : 'lib/presentation/assets/outlet_icon.svg';

      double containerSize = 24.0;

      return Positioned(
        left: position.dx - (containerSize / 2),
        top: position.dy - (containerSize / 2),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoveredConnectionPoints[key] = true),
          onExit: (_) => setState(() => _hoveredConnectionPoints[key] = false),
          child: Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isHovered ? Colors.green.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.rectangle,
              border: Border.all(color: isHovered ? Colors.green : Colors.grey),
            ),
            child: Transform.scale(
              scale: 2,
              child: SvgPicture.asset(
                svgAssetPath,
                color: isHovered ? Colors.black : null,
                fit: BoxFit.contain, // Ensures the SVG fits within the container while maintaining its aspect ratio
              ),
            ),
          ),
        ),
      );
    }).toList();
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
      selectedComponent = component;
      print('Selected component: ${component.id}');
    });
    widget.onComponentSelected?.call(component.id);
  }
  void _deleteComponent(ComponentModel component) {
    setState(() {
      placedComponents.removeWhere((item) => item.id == component.id);
      connections.removeWhere((connection) => connection.startComponentId == component.id || connection.endComponentId == component.id);
    });
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
              final Offset snappedPosition = snapToGrid(localOffset); // Snap the position

              setState(() {
                ComponentModel component = details.data..position = snappedPosition;
                component.updateConnectionPoints(); // Optionally adjust connection points here
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
                              child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected, onDelete: _deleteComponent,),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
                            ),
                            // Inside the onDragEnd or similar method
                            onDragEnd: (dragDetails) {
                              final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                              final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
                              final Offset snappedPosition = snapToGrid(localOffsetCanvas - Offset(50 / 2, 50 / 2)); // Adjust for component's size if necessary

                              setState(() {
                                component.position = snappedPosition;
                                component.updateConnectionPoints(); // Recalculate connection points based on new position
                              });
                            },

                            child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
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


class RankineCycleModel {
  late List<ComponentModel> components;

  void addComponent(ComponentModel component) {
    components.add(component);
  }

  void connectComponents(String fromComponentId, String toComponentId) {
    // Find components by ID and set up their connections
  }

  void calculateCycle() {
    // Iterate through components in the cycle, calculating properties in the correct order
  }
}


abstract class ComponentModel {
  final String id;
  final String type;
  final String imagePath;
  Offset position;
  bool isSelected = false;
  Map<String, Offset> connectionPoints;
  List<String> connectedTo = [];

  Map<String, ComponentModel?> connections = {};

  ComponentModel({
    required this.id,
    required this.type,
    required this.position,
    required this.imagePath,
  }) : connectionPoints = {} {
    updateConnectionPoints();
  }

  Map<String, dynamic> get properties;

  void updateConnectionPoints() {
    connectionPoints = {
      'inlet': Offset(-8, 40),
      'outlet': Offset(85, 40),
    };
    print("update connection points called");
  }
  void connectTo(String connectionPoint, ComponentModel targetComponent) {
    connections[connectionPoint] = targetComponent;
  }
}

class ConnectionPointButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
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

class Turbine extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  Turbine({
    required String id,
    Offset position = Offset.zero,
    this.inletPressure = 0.0,
    this.outletPressure = 0.0,
    this.efficiency = 0.0,
  }):super(id: id, type: "Turbine", position: position, imagePath: 'lib/presentation/assets/turbine_icon.svg');



  @override
  Map<String, dynamic> get properties => {
    "inletPressure": inletPressure,
    "outletPressure": outletPressure,
    "efficiency": efficiency,
  };
}

class Boiler extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  Boiler({
    required String id,
    Offset position = Offset.zero,
    this.inletPressure = 0.0,
    this.outletPressure = 0.0,
    this.efficiency = 0.0,
  }):super(id: id, type: "Boiler", position: position, imagePath: 'lib/presentation/assets/boiler_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "inletPressure": inletPressure,
    "outletPressure": outletPressure,
    "efficiency": efficiency,
  };
}

class Precipitator extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  Precipitator({
    required String id,
    Offset position = Offset.zero,
    this.inletPressure = 0.0,
    this.outletPressure = 0.0,
    this.efficiency = 0.0,
  }):super(id: id, type: "Precipitator", position: position, imagePath: 'lib/presentation/assets/precipitator_icon.svg');



  @override
  Map<String, dynamic> get properties => {
    "inletPressure": inletPressure,
    "outletPressure": outletPressure,
    "efficiency": efficiency,
  };
}

class WaterPump extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  WaterPump({
    required String id,
    Offset position = Offset.zero,
    this.inletPressure = 0.0,
    this.outletPressure = 0.0,
    this.efficiency = 0.0,
  }):super(id: id, type: "WaterPump", position: position, imagePath: 'lib/presentation/assets/water_pump_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "inletPressure": inletPressure,
    "outletPressure": outletPressure,
    "efficiency": efficiency,
  };
}
