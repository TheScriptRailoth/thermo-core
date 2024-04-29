import 'dart:convert';
import 'dart:math';
import 'package:edurank/presentation/pages/home/DraggableWindow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_svg/svg.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
double gridCellSize = 20.0;
enum ComponentType { Turbine, Boiler, Precipitator, Pump, Inlet}
ComponentModel? startComponent;
ComponentModel? endComponent;

class GridPainter extends CustomPainter {

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
    final entries = <ContextMenuEntry>[
      MenuItem(
        label: 'Delete',
        icon: Icons.delete,
        onSelected: () {
          widget.onDelete(widget.component);
        },
      ),
      MenuItem(
        label: 'Flip',
        icon: Icons.flip,
        onSelected: () {
          setState(() {
            widget.component.flip();
          });
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
      Color svgColor = key== 'inlet' ? Color(0xff006633) : Color(0xff0000FF);
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
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(widget.component.isFlipped ? pi : 0),
                child: SvgPicture.asset(
                  svgAssetPath,
                  width: iconSize,
                  height: iconSize,
                  color: svgColor,
                ),
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

  int updatedStage =0;
  List<ComponentModel> placedComponents = [];
  List<Connection> connections = [];
  ComponentModel ?selectedComponent;

  late ConnectionPainter _connectionPainter;

  Connection? currentTappedConnection;


  var result;
  TextEditingController _pressureController = TextEditingController();
  TextEditingController _tempController = TextEditingController();
  TextEditingController _enthalapyController = TextEditingController();
  TextEditingController _entropyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectionPainter = ConnectionPainter(connections: connections, contentValue: connections.length);
    _tempController = TextEditingController();
    _pressureController = TextEditingController();
    _enthalapyController = TextEditingController();
  }

  @override
  void dispose() {
    _tempController.dispose();
    _enthalapyController.dispose();
    _entropyController.dispose();
    _pressureController.dispose();
    super.dispose();
  }

  void _selectComponent(ComponentModel component) {
    setState(() {
      for (var comp in placedComponents) {
        comp.isSelected = false;
      }
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

  Offset snapToGridLine(Offset point, double gridCellSize) {
    double x = (point.dx / gridCellSize).round() * gridCellSize;
    double y = (point.dy / gridCellSize).round() * gridCellSize;
    return Offset(x, y);
  }

  ComponentModel? findComponentByPoint(Offset point) {
    for (var component in placedComponents) {
      Rect bounds = Rect.fromCenter(
          center: component.position,
          width: 70,
          height: 70
      );
      if (bounds.contains(point)) {
        return component;
      }
    }
    return null;
  }

  ComponentModel? findComponentById(String Id) {
    for (var component in placedComponents) {
      if(component.id == Id)
        return component;
    }
    return null;
  }

  bool isValidConnection(ComponentModel startComponent, ComponentModel endComponent) {
    return startComponent.id != endComponent.id;
  }

  void onConnectionStart(ComponentModel component, Offset position, String pointId) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset connectionPointOffset = component.connectionPoints[pointId]!;
    Offset globalPosition = renderBox.localToGlobal(component.position + connectionPointOffset - Offset(355, 28));

    Offset snappedStart = snapToGridLine(globalPosition, gridCellSize);

    setState(() {
      currentConnectionStart = snappedStart;
      currentConnectionEnd = snappedStart;
      startComponent = component;
    });
  }

  void updateComponentPosition(ComponentModel component, Offset newPosition) {
    print("updateComponentPosition Called");
    setState(() {
      component.position = newPosition;
      component.updateConnectionPoints();
      updateConnectionsForComponent(component);
    });
  }
  void updateConnectionsForComponent(ComponentModel component) {
    for (Connection conn in connections) {
      if (conn.startComponentId == component.id) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        conn.startPoint = component.getGlobalPositionOfConnectionPoint('outlet', renderBox);
      }
      if (conn.endComponentId == component.id) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        conn.endPoint = component.getGlobalPositionOfConnectionPoint('inlet', renderBox);
      }
    }
    (context as Element).markNeedsBuild();
  }

  void onConnectionUpdate(DragUpdateDetails details) {
    RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = renderBoxCanvas.globalToLocal(details.globalPosition);

    Offset snappedEnd = snapToGridLine(localPosition, gridCellSize);
    setState(() {
      currentConnectionEnd = snappedEnd;
    });
  }

  ComponentModel? findComponentClosestTo(Offset point) {
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

  bool isEndPointValid(Offset endPoint) {
    for (var component in placedComponents) {
      Offset inletPosition = component.position + component.connectionPoints['inlet']!;
      double hitRadius = 20.0;

      if ((endPoint - inletPosition).distance <= hitRadius) {
        print("Valid inlet found at ${component.position}");
        return true;
      }
    }
    print("No valid inlet found at $endPoint");
    return false;
  }

  void onConnectionEnd() {
    if (currentConnectionStart != null && currentConnectionEnd != null) {
      Offset snappedEnd = snapToGridLine(currentConnectionEnd!, gridCellSize);
      endComponent = findComponentClosestTo(currentConnectionEnd!);

      if (endComponent != null && isEndPointValid(snappedEnd!)) {
        createConnection(
            startComponent!.id,
            endComponent!.id,
            currentConnectionStart!,
            currentConnectionEnd!
        );
        showAlertOnCycleCompletion();
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Invalid Connection"),
              content: Text("Connections must end on a valid inlet."),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK")
                )
              ],
            )
        );
        setState(() {
          currentConnectionStart = null;
          currentConnectionEnd = null;
        });
      }
    }
  }

  void onComponentTap(ComponentModel component) {
    setState(() {
      if (selectedComponent != component) {
        selectedComponent?.isSelected = false;
        selectedComponent = component;
        selectedComponent?.isSelected = true;
      }
    });
  }

  void _showContextMenuConnectionLine(BuildContext context, Offset position, Connection connection) {
    print("Context menu triggered for connection from ${connection.startComponentId} to ${connection.endComponentId}");
    final RelativeRect positionRect = RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy);

    showMenu(
        context: context,
        position: positionRect,
        items: <PopupMenuEntry>[
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete Connection'),
            onTap: () {
              print("Delete tapped");
            },
          ),
        ]
    ).then((value) {
      if (value == 'delete') {
        print("Deleting connection");
        _deleteConnectionLine(connection);
      }
    });
  }

  void _deleteConnectionLine(Connection connection) {
    setState(() {
      connections.removeWhere((conn) => conn == connection);
      print("Connection deleted, remaining connections: ${connections.length}");
    });
  }

  void createConnection(String startComponentId, String endComponentId, Offset startPoint, Offset endPoint) {
    ComponentModel startComponent = placedComponents.firstWhere((comp) => comp.id == startComponentId);
    ComponentModel endComponent = placedComponents.firstWhere((comp) => comp.id == endComponentId);

    ComponentModel? inletComponent = findComponentById(startComponentId);
    ComponentModel? outletComponent = findComponentById(endComponentId);

    if (inletComponent == null || outletComponent == null) {
      print("Error: Failed to find valid inlet or outlet components.");
      return;
    }

    Connection newConnection = Connection(
      startComponentId: startComponent.id,
      endComponentId: endComponent.id,
      startPoint: startPoint,
      endPoint: endPoint,
      stage: connections.length+1,
      inletComponent: inletComponent,
      outletComponent: outletComponent,
    );

    setState(() {
      connections.add(newConnection);
      startComponent.addConnection(newConnection);
      endComponent.addConnection(newConnection);
    });

    print('Connection added:');
    print('Start Component : ${startComponent.type} (ID: ${startComponent.id})');
    print('End Component: ${endComponent.type} (ID: ${endComponent.id})');
    print('Start Point: ${newConnection.startPoint}');
    print('End Point: ${newConnection.endPoint}');
  }

  void showAlertOnCycleCompletion() {
    if (isCycleComplete()) {
      print("Cycle is complete.");
      showDialog(context: context, 
          builder: (BuildContext context){
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 30,),
                    const Text("Cycle Complete"),
                  ],
                ),
                content: const Text("The cycle has been successfully completed. \nNow you can edit the properties"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
          }
      );
    }
  }
  bool isCycleComplete() {
    if (connections.isEmpty || placedComponents.isEmpty) return false;

    // Map each component to its connections
    Map<String, List<String>> graph = {};
    for (var connection in connections) {
      graph.putIfAbsent(connection.startComponentId, () => []);
      graph.putIfAbsent(connection.endComponentId, () => []);
      graph[connection.startComponentId]!.add(connection.endComponentId);
    }

    Set<String> visited = {};
    bool hasCycle = false;

    String startComponent = connections.first.startComponentId;

    // DFS to detect a cycle
    bool dfs(String node, String parent) {
      if (visited.contains(node)) {
        return node == startComponent; // Return true if it comes back to the start
      }

      visited.add(node);
      for (var neighbor in graph[node]!) {
        if (neighbor != parent) { // Avoid going back to the parent node
          if (dfs(neighbor, node)) {
            return true;
          }
        }
      }
      return false;
    }

    // Check for cycle starting from the first component
    hasCycle = dfs(startComponent, "");

    // Ensure all components were visited (i.e., all are connected)
    bool allVisited = placedComponents.every((comp) => visited.contains(comp.id));

    return hasCycle && allVisited;
  }

  OverlayEntry? overlayEntry;
  Offset overlayPosition = Offset(100, 100);
  void _updateOverlayPosition(DragUpdateDetails details) {
      overlayPosition += details.delta;
      overlayEntry?.markNeedsBuild();
  }

  void _showOverlay(BuildContext context) {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayPosition.dy,
        left: overlayPosition.dx,
        width: 400,
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          child: PropertyEditWindow(
            onClose: () {
              overlayEntry?.remove();
              overlayEntry = null;

            },
            onDrag: _updateOverlayPosition,
            stage: currentTappedConnection!.stage,
            inletComponent: currentTappedConnection!.inletComponent,
            outletComponent: currentTappedConnection!.outletComponent,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  void onCanvasTap() {
    setState(() {
      selectedComponent?.isSelected = false;
      selectedComponent = null;
    });
  }

  int stageUpdater(){
    int stage=0;
    if(currentTappedConnection?.inletComponent.type =='Boiler' && currentTappedConnection?.outletComponent.type =='Turbine')
      stage=1;
    else if (currentTappedConnection?.inletComponent.type =='Turbine' && currentTappedConnection?.outletComponent.type =='Precipitator')
      stage=2;
    else if(currentTappedConnection?.inletComponent.type =='Precipitator' && currentTappedConnection?.outletComponent.type =='Pump')
      stage=3;
    else if(currentTappedConnection?.inletComponent.type =='Pump' && currentTappedConnection?.outletComponent.type =='Boiler')
      stage=4;
    return stage;
  }


  @override
  Widget build(BuildContext context) {
    updatedStage =stageUpdater();
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
      onTapUp: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        final Connection? tappedConnection = _connectionPainter.checkHit(localPosition);
        if (tappedConnection != null) {
          print("Tapped on connection from ${tappedConnection.startComponentId} to ${tappedConnection.endComponentId}");
          setState(() {
            currentTappedConnection = tappedConnection;
          });
          if(isCycleComplete())
          _showOverlay(context);
          else{
            showDialog(
                context: context, builder: (BuildContext context){
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning_amber_outlined),
                        Text(" Cycle is not complete yet "),
                      ],
                    ),
                    content: Text("Complete the cycle first then you will be able to edit properties."),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
            }
            );
          }
        } else {
          print("Tap position: $localPosition did not hit any connections.");
        }
      },

      onSecondaryTapUp: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        final Connection? tappedConnection = _connectionPainter.checkHit(localPosition);
        if (tappedConnection != null) {
          _showContextMenuConnectionLine(context, details.globalPosition, tappedConnection);
        }
      },

      child: CustomPaint(
          painter: GridPainter(),
          foregroundPainter: ConnectionPainter(
            connections: connections,
            currentConnectionStart: currentConnectionStart,
            currentConnectionEnd: currentConnectionEnd,
            contentValue: connections.length,
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
                    clipBehavior: Clip.none,
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
                              final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
                              final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
                              final Offset snappedPosition = snapToGrid(localOffsetCanvas - const Offset(35, 35));

                              setState(() {
                                var index = placedComponents.indexWhere((comp) => comp.id == component.id);
                                if (index != -1) {
                                  var updatedComponent = component.copyWith(position: snappedPosition);
                                  placedComponents[index] = updatedComponent;
                                  updateComponentPosition(updatedComponent, snappedPosition);
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
      case ComponentType.Pump:
        return Pump(id: id,position: position);
      default:
        throw Exception("Unknown component type");
    }
  }
}

abstract class ComponentModel {
  bool isFlipped =false;

  final String id;
  final String type;
  final String imagePath;
  Offset position;
  bool isSelected = false;
  Map<String, Offset> connectionPoints;
  List<Connection> connections = [];

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

  void flip() {
    isFlipped = !isFlipped;
    updateConnectionPoints();
  }

  void updateConnectionPoints() {
    if(isFlipped){
      connectionPoints = {
        'outlet': Offset(0, 40),
        'inlet': Offset(79, 40),
      };
    }else {
      connectionPoints = {
        'inlet': Offset(0, 40),
        'outlet': Offset(79, 40),
      };
    }

  }

  Offset getGlobalPositionOfConnectionPoint(String pointId, RenderBox renderBox) {
    if (!renderBox.hasSize) {
      return Offset.zero;
    }
    Offset localPosition = position + connectionPoints[pointId]!;
    return renderBox.localToGlobal(localPosition) - Offset(355, 28);
  }

  bool hitTest(Offset point) {
    Offset inletPosition = position + connectionPoints['inlet']!;
    double hitRadius = 20.0;  // Increase if needed
    bool hit = (point - inletPosition).distance <= hitRadius;
    if (hit) {
      print("Hit detected at inlet at $inletPosition");
    }
    return hit;
  }

  void addConnection(Connection connection) {
    connections.add(connection);
  }

  void removeConnection(Connection connection) {
    connections.removeWhere((c) => c == connection);
  }

}

class Turbine extends ComponentModel {
  double temprature;
  double pressure;
  double efficiency;
  double entropy;
  double enthalapy;

  Turbine({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?> connectedTo = const {},
    this.temprature=0.0,
    this.pressure=0.0,
    this.efficiency = 0.0,
    this.enthalapy=0.0,
    this.entropy=0.0,
  }) : super(id: id, type: "Turbine", position: position, imagePath: 'lib/presentation/assets/turbine_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "pressure": pressure,
    "efficiency": efficiency,
    "enthalapy" : enthalapy,
    "entropy" : entropy,
    "temperature" : temprature,
  };

  @override
  Turbine copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? pressure,
    double? efficiency,
    double? enthalapy,
    double? entropy,
    double? temprature,
  }) {
    return Turbine(
      id: id ?? this.id,
      position: position ?? this.position,
      pressure: pressure ?? this.pressure,
      efficiency: efficiency ?? this.efficiency,
      enthalapy: enthalapy?? this.enthalapy,
      entropy: entropy?? this.entropy,
      temprature: temprature?? this.temprature,
    );
  }

  void updateWith({
    double? pressure,
    double? efficiency,
    double? enthalapy,
    double? entropy,
  }) {
    if (pressure != null) this.pressure = pressure;
    if (efficiency != null) this.efficiency = efficiency;
    if (enthalapy != null) this.enthalapy = enthalapy;
    if (entropy != null) this.entropy = entropy;
  }
}
class Boiler extends ComponentModel{
  double pressure;
  double enthalapy;
  double entropy;

  Boiler({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?>? connectedTo,

    this.pressure=0.0,
    this.entropy = 0.0,
    this.enthalapy=0.0,
  }):super(id: id, type: "Boiler", position: position, imagePath: 'lib/presentation/assets/boiler_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "pressure": pressure,
    "enthalapy" : enthalapy,
    "entropy" : entropy,
  };

  @override
  Boiler copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? pressure,
    double? efficiency,
    double? enthalapy,
    double? entropy,
  }) {
    return Boiler(
      id: id ?? this.id,
      position: position ?? this.position,

      pressure: pressure ?? this.pressure,
      entropy: entropy?? this.entropy,
      enthalapy: enthalapy?? this.enthalapy,
    );
  }

  void updateWith({
    double? pressure,
    double? efficiency,
    double? enthalapy,
    double? entropy,
  }) {
    if (pressure != null) this.pressure = pressure;
    if (enthalapy != null) this.enthalapy = enthalapy;
    if (entropy != null) this.entropy = entropy;
    if (enthalapy != null) this.entropy = enthalapy;
  }

}
class Precipitator extends ComponentModel{
  double pressure;
  double entropy;
  double enthalapy;

  Precipitator({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?>? connectedTo,

    this.pressure=0.0,
    this.entropy = 0.0,
    this.enthalapy =0.0,
  }):super(id: id, type: "Precipitator", position: position, imagePath: 'lib/presentation/assets/precipitator_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "pressure": pressure,
    "entropy" : entropy,
    "enthalapy" : enthalapy,
  };

  @override
  Precipitator copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? inletPressure,
    double? outletPressure,
    double? efficiency,
    double? entropy,
    double? enthalapy,
  }) {
    return Precipitator(
      id: id ?? this.id,
      position: position ?? this.position,

      pressure: pressure ?? this.pressure,
      enthalapy: enthalapy?? this.enthalapy,
      entropy: entropy ?? this.entropy,
    );
  }

  void updateWith({
    double? pressure,
    double? efficiency,
    double? enthalapy,
    double? entropy,
  }) {
    if (pressure != null) this.pressure = pressure;
    if (enthalapy != null) this.enthalapy = enthalapy;
    if (entropy != null) this.entropy = entropy;
  }
}
class Pump extends ComponentModel{
  double pressure;
  double efficiency;
  double entropy;
  double enthalapy;

  Pump({
    required String id,
    Offset position = Offset.zero,
    Map<String, ConnectionEndpoint?>? connectedTo,

    this.pressure =0.0,
    this.efficiency = 0.0,
    this.entropy=0.0,
    this.enthalapy=0.0,
  }):super(id: id, type: "Pump", position: position, imagePath: 'lib/presentation/assets/water_pump_icon.svg');

  @override
  Map<String, dynamic> get properties => {
    "pressure" : pressure,
    "efficiency": efficiency,
    "entropy":entropy,
    "enthalapy" : enthalapy,
  };

  @override
  Pump copyWith({
    String? id,
    Offset? position,
    Map<String, ConnectionEndpoint?>? connectedTo,

    double? pressure,
    double? efficiency,
    double? entropy,
    double? enthalapy,
  }) {
    return Pump(
      id: id ?? this.id,
      position: position ?? this.position,

      pressure: pressure ?? this.pressure,
      efficiency: efficiency ?? this.efficiency,
      entropy: entropy ?? this.entropy,
      enthalapy: enthalapy?? this.enthalapy,
    );
  }
  void updateWith({
    double? pressure,
    double? efficiency,
    double? enthalapy,
    double? entropy,
  }) {
    if (pressure != null) this.pressure = pressure;
    if (enthalapy != null) this.enthalapy = enthalapy;
    if (entropy != null) this.entropy = entropy;
    if (enthalapy != null) this.entropy = enthalapy;
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
  int stage;
  ComponentModel inletComponent;
  ComponentModel outletComponent;

  Connection({
    required this.startPoint,
    required this.endPoint,
    required this.startComponentId,
    required this.endComponentId,
    required this.stage,
    required this.inletComponent,
    required this.outletComponent,
  });

  Rect getHitZone(double touchWidth) {
    final double halfWidth = touchWidth / 2;
    final Offset direction = endPoint - startPoint;
    final double length = direction.distance;
    final Offset unitDirection = direction / length;
    final Offset normal = Offset(-unitDirection.dy, unitDirection.dx);
    final List<Offset> points = [
      startPoint + normal * halfWidth,
      startPoint - normal * halfWidth,
      endPoint - normal * halfWidth,
      endPoint + normal * halfWidth
    ];

    double left = points.map((p) => p.dx).reduce(min);
    double right = points.map((p) => p.dx).reduce(max);
    double top = points.map((p) => p.dy).reduce(min);
    double bottom = points.map((p) => p.dy).reduce(max);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Map<String, dynamic> calculateProperties() {
    return {};
  }
}

class ConnectionPainter extends CustomPainter {
  List<Connection> connections;
  Offset? currentConnectionStart;
  Offset? currentConnectionEnd;
  final int contentValue;

  ConnectionPainter({
    required this.connections,
    required this.contentValue,
    this.currentConnectionStart,
    this.currentConnectionEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    for (Connection connection in connections) {
      canvas.drawLine(connection.startPoint, connection.endPoint, paint);
    }

    if (currentConnectionStart != null && currentConnectionEnd != null) {
      paint.color = Colors.blue;
      canvas.drawLine(currentConnectionStart!, currentConnectionEnd!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return true;
  }

  Connection? checkHit(Offset position) {
    final double touchArea = 20.0; // Ensure this is large enough
    for (Connection connection in connections) {
      Rect hitZone = connection.getHitZone(touchArea);
      if (hitZone.contains(position)) {
        print("Hit detected on: ${connection.startComponentId} to ${connection.endComponentId}");
        return connection;
      }
    }
    print("No hit detected at position $position, checked zones: ${connections.map((e) => e.getHitZone(touchArea))}");
    return null;
  }
}

class ConnectionDragData {
  final String componentId;
  final String pointId;
  final Offset position;

  ConnectionDragData({required this.componentId, required this.pointId, required this.position});
}



