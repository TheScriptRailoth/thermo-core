import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_svg/svg.dart';
import 'home_screen.dart';
enum ComponentType { Turbine, Boiler, Precipitator, WaterPump}

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

  List<Widget> _buildConnectionPoints() {
    double containerSize = 30.0; // For hover detection area
    double iconSize = 50.0; // Actual size of the connection point icons
    String inletSvgAssetPath = 'lib/presentation/assets/inlet_icon.svg';
    String outletSvgAssetPath = 'lib/presentation/assets/outlet_icon.svg';

    return widget.component.connectionPoints.entries.map((entry) {
      final key = entry.key;
      final position = entry.value;
      String svgAssetPath = key == 'inlet' ? inletSvgAssetPath : outletSvgAssetPath;
      double left = position.dx - (containerSize / 2);
      double top = position.dy - (containerSize / 2);

      bool isHovered = _hoveredConnectionPoints[key] ?? false;
      return Positioned(
        left: left,
        top: top,
        child: MouseRegion(
          onEnter: (_) => setState(() {
            _hoveredConnectionPoints[key] = true;
          }),
          onExit: (_) => setState(() {
            _hoveredConnectionPoints[key] = false;
          }),
          child: Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: Colors.transparent, // For visibility during development, you might set a color
              borderRadius: BorderRadius.circular(10),
              border: isHovered ? Border.all(color: Colors.blue, width: 2) : Border.all(color: Colors.transparent), // Show border if hovered
            ),
            child: SvgPicture.asset(
              svgAssetPath,
              width: iconSize,
              height: iconSize,
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
// class _RankineCycleCanvasState extends State<RankineCycleCanvas> {
//   List<ComponentModel> placedComponents = [];
//   List<Connection> connections = [];
//   ComponentModel ?selectedComponent;
//
//   void addConnection(Connection connection) {
//     setState(() {
//       connections.add(connection);
//     });
//   }
//
//   void _selectComponent(ComponentModel component) {
//     setState(() {
//       // Deselect all components
//       for (var comp in placedComponents) {
//         comp.isSelected = false;
//       }
//       // Select the tapped component
//       component.isSelected = true;
//       selectedComponent = component;
//       print('Selected component: ${component.id}');
//     });
//     widget.onComponentSelected?.call(component.id);
//   }
//   void _deleteComponent(ComponentModel component) {
//     setState(() {
//       placedComponents.removeWhere((item) => item.id == component.id);
//     });
//   }
//
//   final GlobalKey _canvasKey = GlobalKey();
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: (){
//         if(selectedComponent!=null){
//           setState(() {
//             for(var comp in placedComponents){
//               comp.isSelected=false;
//               widget.onComponentSelected?.call(null);
//             }
//           });
//         }
//       },
//       child: CustomPaint(
//           painter: GridPainter(),
//           child: DragTarget<DraggableComponentData>(
//             onWillAccept: (data) => true,
//             onAcceptWithDetails: (DragTargetDetails<DraggableComponentData> details) {
//               final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
//               final Offset localOffset = renderBox.globalToLocal(details.offset);
//               final Offset snappedPosition = snapToGrid(localOffset);
//               setState(() {
//                 if (details.data.isNew) {
//                   ComponentModel newComponent = details.data.component.copyWith(
//                     id: UniqueKey().toString(),
//                     position: snappedPosition,
//                   );
//                   placedComponents.add(newComponent);
//                 } else {
//                   // Move existing component
//                   var foundIndex = placedComponents.indexWhere((component) => component.id == details.data.component.id);
//                   if (foundIndex != -1) {
//                     placedComponents[foundIndex] = placedComponents[foundIndex].copyWith(position: snappedPosition);
//                   }
//                 }
//               });
//             },
//             builder: (context, candidateData, rejectedData) {
//               return Container(
//                 key: _canvasKey,
//                 color: Colors.white,
//                 child: CustomPaint(
//                   painter: GridPainter(),
//                   child: Stack(
//                     children: placedComponents.map((component) {
//                       return Positioned(
//                         left: component.position.dx,
//                         top: component.position.dy,
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectComponent(component);
//                             });
//                           },
//                           child: Draggable<DraggableComponentData>(
//                               data: DraggableComponentData(component, isNew: false),
//                             feedback: Material(
//                               elevation: 4.0,
//                               child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected, onDelete: _deleteComponent,),
//                             ),
//                             childWhenDragging: Opacity(
//                               opacity: 0.5,
//                               child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
//                             ),
//
//                             onDragEnd: (dragDetails) {
//                               // Adjusting an existing component's position
//                               final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
//                               final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
//                               final Offset snappedPosition = snapToGrid(localOffsetCanvas - const Offset(35, 35)); // Adjust based on actual size
//
//                               // Update existing component's position
//                               setState(() {
//                                 var index = placedComponents.indexWhere((comp) => comp.id == component.id);
//                                 if (index != -1) {
//                                   var updatedComponent = component.copyWith(position: snappedPosition);
//                                   placedComponents[index] = updatedComponent;
//                                 }
//                               });
//                             },
//                             child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//
//               );
//             },
//           )
//       ),
//     );
//   }
// }

class _RankineCycleCanvasState extends State<RankineCycleCanvas> {
  List<ComponentModel> placedComponents = [];
  List<Connection> connections = [];
  ComponentModel ?selectedComponent;

  void addConnection(Connection connection) {
    setState(() {
      connections.add(connection);
    });
  }

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
      child: Container(
        key: _canvasKey,
        color: Colors.white,
        child: Stack(
          children: [
            CustomPaint(
              painter: GridPainter(),
              child: Container(),
            ),
            CustomPaint(
              painter: ConnectionPainter(connections),
              child: buildComponents(),
            )
          ],
        ),
      )
    );
  }

  Widget buildComponents() {
    return Stack(
      children: placedComponents.map((component) {
        return Positioned(
            left: component.position.dx,
            top: component.position.dy,
            child: DragTarget<DraggableComponentData>(
              onWillAccept: (data) => true,
              onAcceptWithDetails: (DragTargetDetails<DraggableComponentData> details) {
                final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                final Offset localOffset = renderBox.globalToLocal(details.offset);
                final Offset snappedPosition = snapToGrid(localOffset);
                setState(() {
                  if (details.data.isNew) {
                    ComponentModel newComponent = details.data.component.copyWith(
                      id: UniqueKey().toString(),
                      position: snappedPosition,
                    );
                    placedComponents.add(newComponent);
                  } else {
                    // Move existing component
                    var foundIndex = placedComponents.indexWhere((component) => component.id == details.data.component.id);
                    if (foundIndex != -1) {
                      placedComponents[foundIndex] = placedComponents[foundIndex].copyWith(position: snappedPosition);
                    }
                  }
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
                            child: Draggable<DraggableComponentData>(
                              data: DraggableComponentData(component, isNew: false),
                              feedback: Material(
                                elevation: 4.0,
                                child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected, onDelete: _deleteComponent,),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: ComponentWidget(component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
                              ),

                              onDragEnd: (dragDetails) {
                                // Adjusting an existing component's position
                                final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                                final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
                                final Offset snappedPosition = snapToGrid(localOffsetCanvas - const Offset(35, 35)); // Adjust based on actual size

                                // Update existing component's position
                                setState(() {
                                  var index = placedComponents.indexWhere((comp) => comp.id == component.id);
                                  if (index != -1) {
                                    var updatedComponent = component.copyWith(position: snappedPosition);
                                    placedComponents[index] = updatedComponent;
                                  }
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
        );
      }).toList(),
    );
  }
}

class DraggableComponentData {
  final ComponentModel component;
  final bool isNew;

  DraggableComponentData(this.component, {this.isNew = true});
}
class ComponentFactory {
  static ComponentModel createComponent(ComponentType type, Offset position) {
    final String id = UniqueKey().toString();

    switch (type) {
      case ComponentType.Turbine:
        return Turbine(id: id, position: position);
      case ComponentType.Boiler:
        return Boiler(id: id, position: position);
      case ComponentType.Precipitator:
        return Precipitator(id: id, position:position);
      case ComponentType.WaterPump:
        return WaterPump(id: id,position: position);
      default:
        throw Exception("Unknown component type");
    }
  }
}

abstract class ComponentModel {
  final String id;
  final String type;
  final String imagePath;
  Offset position;
  bool isSelected = false;
  Map<String, Offset> connectionPoints;
  Map<String, ConnectionEndpoint?> connectedTo={};

  ComponentModel copyWith({
    String? id,
    Offset? position,
    Map<String,ConnectionEndpoint?>? connectedTo,
  });
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
      'inlet': Offset(0, 40),
      'outlet': Offset(79, 40),
    };
    print("update connection points called");
  }
}

class Turbine extends ComponentModel {
  double inletPressure;
  double outletPressure;
  double efficiency;

  Turbine({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?> connectedTo = const {},

    this.inletPressure = 0.0,
    this.outletPressure = 0.0,
    this.efficiency = 0.0,
  }) : super(id: id, type: "Turbine", position: position, imagePath: 'lib/presentation/assets/turbine_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "inletPressure": inletPressure,
    "outletPressure": outletPressure,
    "efficiency": efficiency,
  };

  @override
  Turbine copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? inletPressure,
    double? outletPressure,
    double? efficiency,
  }) {
    return Turbine(
      id: id ?? this.id,
      position: position ?? this.position,
      connectedTo: connectedTo ?? this.connectedTo,

      inletPressure: inletPressure ?? this.inletPressure,
      outletPressure: outletPressure ?? this.outletPressure,
      efficiency: efficiency ?? this.efficiency,
    );
  }
}
class Boiler extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  Boiler({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?>? connectedTo,

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

  @override
  Boiler copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? inletPressure,
    double? outletPressure,
    double? efficiency,
  }) {
    return Boiler(
      id: id ?? this.id,
      position: position ?? this.position,
      connectedTo: connectedTo ?? this.connectedTo,

      inletPressure: inletPressure ?? this.inletPressure,
      outletPressure: outletPressure ?? this.outletPressure,
      efficiency: efficiency ?? this.efficiency,
    );
  }
}
class Precipitator extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  Precipitator({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?>? connectedTo,

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

  @override
  Precipitator copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? inletPressure,
    double? outletPressure,
    double? efficiency,
  }) {
    return Precipitator(
      id: id ?? this.id,
      position: position ?? this.position,
      connectedTo: connectedTo ?? this.connectedTo,

      inletPressure: inletPressure ?? this.inletPressure,
      outletPressure: outletPressure ?? this.outletPressure,
      efficiency: efficiency ?? this.efficiency,
    );
  }
}
class WaterPump extends ComponentModel{
  double inletPressure;
  double outletPressure;
  double efficiency;

  WaterPump({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?>? connectedTo,

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

  @override
  WaterPump copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? inletPressure,
    double? outletPressure,
    double? efficiency,
  }) {
    return WaterPump(
      id: id ?? this.id,
      position: position ?? this.position,
      connectedTo: connectedTo ?? this.connectedTo,

      inletPressure: inletPressure ?? this.inletPressure,
      outletPressure: outletPressure ?? this.outletPressure,
      efficiency: efficiency ?? this.efficiency,
    );
  }
}

class ConnectionEndpoint {
  String componentId;
  String pointId;

  ConnectionEndpoint({required this.componentId, required this.pointId});
}

class Connection {
  Offset startPoint;
  Offset endPoint;
  String startComponentId;
  String endComponentId;

  Connection({
    required this.startPoint,
    required this.endPoint,
    required this.startComponentId,
    required this.endComponentId,
  });
}

class ConnectionPainter extends CustomPainter {
  final List<Connection> connections;

  ConnectionPainter(this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red // Connection line color
      ..strokeWidth = 2; // Connection line width

    // Draw each connection
    for (var connection in connections) {
      canvas.drawLine(connection.startPoint, connection.endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return oldDelegate.connections != connections;
  }
}


