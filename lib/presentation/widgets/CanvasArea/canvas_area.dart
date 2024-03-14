// import 'dart:math';
// import 'package:flutter/material.dart';
// import '../../../core/utils/grid_painter.dart';
// import '../../../main.dart';
// import '../../../models/cycle_components_model.dart';
// import '../CycleObjects/cycle_objects.dart';
// class RankineCycleCanvas extends StatefulWidget {
//   @override
//   _RankineCycleCanvasState createState() => _RankineCycleCanvasState();
// }
//
// class _RankineCycleCanvasState extends State<RankineCycleCanvas> {
//   List<ComponentModel> placedComponents = [];
//   List<Map<String, dynamic>> connections = [];
//   final GlobalKey _canvasKey = GlobalKey();
//
//   @override
//   Widget build(BuildContext context) {
//     return DragTarget<ComponentModel>(
//       onWillAccept: (data) => true,
//       onAcceptWithDetails: (details) {
//         final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
//         final Offset localOffset = renderBox.globalToLocal(details.offset);
//
//         setState(() {
//           // Here we adjust the localOffset by taking into account the initial drag position within the component
//           // Assuming sidebar width is 200, we need to subtract this from the dropped position's X coordinate
//           details.data.position = localOffset - const Offset(200, 0);
//           placedComponents.add(details.data);
//         });
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           key: _canvasKey,
//           color: Colors.white,
//           child: CustomPaint(
//             painter: GridPainter(),
//             child: Stack(
//               children: placedComponents.map((component) {
//                 return Positioned(
//                   left: component.position.dx,
//                   top: component.position.dy,
//                   child: Draggable<ComponentModel>(
//                     data: component,
//                     feedback: Material(
//                       elevation: 4.0,
//                       child: ComponentWidget(type: component.type),
//                     ),
//                     childWhenDragging: Opacity(
//                       opacity: 0.5,
//                       child: ComponentWidget(type: component.type),
//                     ),
//                     onDragEnd: (dragDetails) {
//                       // Instead of subtracting the sidebar width, directly use the converted local offset
//                       final RenderBox renderBoxCanvas = _canvasKey.currentContext!.findRenderObject() as RenderBox;
//                       final Offset localOffsetCanvas = renderBoxCanvas.globalToLocal(dragDetails.offset);
//
//                       setState(() {
//                         // Directly set the component's new position based on the local offset within the canvas
//                         component.position = Offset(
//                           max(0, localOffsetCanvas.dx),
//                           max(0, localOffsetCanvas.dy),
//                         );
//                       });
//                     },
//                     child: ComponentWidget(type: component.type),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
