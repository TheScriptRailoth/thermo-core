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
  final Function(ComponentModel, Offset, String) onConnectionStart;
  final Function(DragUpdateDetails) onConnectionUpdate;
  final Function() onConnectionEnd;

  const ComponentWidget({
    Key? key,
    required this.component,
    required this.onSelect,
    this.isSelected=false,
    required this.onDelete,
    required this.onConnectionStart,
    required this.onConnectionUpdate,
    required this.onConnectionEnd,
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
          ..._buildConnectionPoints(),
        ],
      ),
    );
  }
  List<Widget> _buildConnectionPoints() {
    double containerSize = 30.0;
    double iconSize = 50.0;
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
        child: GestureDetector(
          onPanStart: (details){
            if(key=="outlet"){
              widget.onConnectionStart(widget.component,position,key);
            }
          },
          onPanUpdate: (details){
            widget.onConnectionUpdate(details);
          },
          onPanEnd: (details){
            widget.onConnectionEnd();
          },
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isHovered ? Border.all(color: Colors.blue, width: 2) : Border.all(color: Colors.transparent),
              ),
              child: SvgPicture.asset(
                svgAssetPath,
                width: iconSize,
                height: iconSize,
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
  ComponentModel ?selectedComponent;

  void addConnection(Connection connection) {
    setState(() {
      connections.add(connection);

      print('Connection added:');
      print('Start Component ID: ${connection.startComponentId}');
      print('End Component ID: ${connection.endComponentId}');
      print('Start Point: ${connection.startPoint}');
      print('End Point: ${connection.endPoint}');
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


  Offset? currentConnectionStart;
  Offset? currentConnectionEnd;

  ComponentModel? findComponentByPoint(Offset point) {
    for (var component in placedComponents) {
      Rect bounds = Rect.fromCenter(
          center: component.position,
          width: 70,  // Assuming width and height of the component visuals
          height: 70
      );
      if (bounds.contains(point)) {
        return component;
      }
    }
    return null;
  }

  bool isValidConnection(ComponentModel startComponent, ComponentModel endComponent) {
    return startComponent.id != endComponent.id;
  }

  void onConnectionStart(ComponentModel component, Offset position, String pointId) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = Offset(position.dx + component.connectionPoints[pointId]!.dx,
        position.dy + component.connectionPoints[pointId]!.dy);
    Offset globalPosition = renderBox.localToGlobal(localPosition);

    setState(() {
      currentConnectionStart = globalPosition;
      currentConnectionEnd = globalPosition; // This initializes the end at the start
    });
  }

  void onConnectionUpdate(DragUpdateDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      currentConnectionEnd = localPosition;
    });
  }

  ComponentModel? findComponentClosestTo(Offset point) {
    // This function needs to determine the closest component, optionally focusing on valid inlets
    double closestDist = double.infinity;
    ComponentModel? closestComp;
    for (var component in placedComponents) {
      double dist = (component.position - point).distance;
      if (dist < closestDist) {
        closestDist = dist;
        closestComp = component;
      }
    }
    return closestComp;
  }

  void onConnectionEnd() {
    if (currentConnectionStart != null && currentConnectionEnd != null) {
      // Convert currentConnectionEnd from local to global if necessary
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      Offset globalEndPosition = renderBox.localToGlobal(currentConnectionEnd!);

      // Find the closest component that is not the start component
      ComponentModel? startComponent = findComponentByPoint(currentConnectionStart!);
      ComponentModel? endComponent = findComponentClosestTo(globalEndPosition);

      // Check if the end component is valid and not the same as the start component
      if (endComponent != null && startComponent != endComponent && isValidConnection(startComponent!, endComponent)) {
        // Assuming the end component has a method to get its inlet position
        Offset endPosition = endComponent.connectionPoints['inlet'] ?? endComponent.position;

        // Create a connection to the inlet point of the end component
        addConnection(new Connection(
            startPoint: currentConnectionStart!,
            endPoint: endPosition,
            startComponentId: startComponent.id,
            endComponentId: endComponent.id
        ));
      }

      // Reset connection points
      setState(() {
        currentConnectionStart = null;
        currentConnectionEnd = null;
      });
    }
  }



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
      child: CustomPaint(
          painter: GridPainter(),
          foregroundPainter: ConnectionPainter(
            connections: connections,
            currentConnectionStart: currentConnectionStart,
            currentConnectionEnd: currentConnectionEnd,
          ),
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
                              child: ComponentWidget( onConnectionStart: onConnectionStart, onConnectionEnd: onConnectionEnd, onConnectionUpdate: onConnectionUpdate, component: component, onSelect: _selectComponent, isSelected: component.isSelected, onDelete: _deleteComponent,),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: ComponentWidget(onConnectionStart: onConnectionStart, onConnectionEnd: onConnectionEnd, onConnectionUpdate: onConnectionUpdate,component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
                            ),

                            onDragEnd: (dragDetails) {
                              // Adjusting an existing component's position
                              final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                              final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
                              final Offset snappedPosition = snapToGrid(localOffsetCanvas - const Offset(35, 35));

                              // Update existing component's position
                              setState(() {
                                var index = placedComponents.indexWhere((comp) => comp.id == component.id);
                                if (index != -1) {
                                  var updatedComponent = component.copyWith(position: snappedPosition);
                                  placedComponents[index] = updatedComponent;
                                }
                              });
                            },
                            child: ComponentWidget(onConnectionStart: onConnectionStart, onConnectionEnd: onConnectionEnd, onConnectionUpdate: onConnectionUpdate,component: component, onSelect: _selectComponent, isSelected: component.isSelected,onDelete: _deleteComponent),
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
  final Offset? currentConnectionStart;
  final Offset? currentConnectionEnd;

  ConnectionPainter({
    required this.connections,
    this.currentConnectionStart,
    this.currentConnectionEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    // Debug: Print number of connections
    print("Drawing ${connections.length} connections.");

    for (var connection in connections) {
      // Debug: Print connection details
      print('Drawing connection from ${connection.startPoint} to ${connection.endPoint}');
      canvas.drawLine(connection.startPoint, connection.endPoint, paint);
    }

    if (currentConnectionStart != null && currentConnectionEnd != null) {
      paint.color = Colors.blue;
      canvas.drawLine(currentConnectionStart!, currentConnectionEnd!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return true; // Always repaint for simplicity
  }
}

class ConnectionDragData {
  final String componentId;
  final String pointId;
  final Offset position;

  ConnectionDragData({required this.componentId, required this.pointId, required this.position});
}



