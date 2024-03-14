// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../../main.dart';
// import '../../../models/cycle_components_model.dart';
//
// class ComponentSidebar extends StatelessWidget {
//   final List<String> components = ['lib/presentation/assets/turbine_icon.svg', 'lib/presentation/assets/boiler_icon.svg', 'lib/presentation/assets/precipitator_icon.svg', 'lib/presentation/assets/water_pump_icon.svg'];
//   final List<String> componentsTitle = ['Turbine', "Boiler", "Precipitator", "Water Pump" ];
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 200,
//       color: Colors.grey[200],
//       child: ListView.builder(
//         itemCount: components.length,
//         itemBuilder: (context, index) {
//           return Draggable<ComponentModel>(
//             // Here we create a new ComponentModel with a unique ID for each draggable component
//             data: ComponentModel(
//               id: UniqueKey().toString(), // Generate a unique ID
//               type: components[index],
//               position: Offset.zero,
//             ),
//             feedback: Material(
//               child: Container(
//                 padding: EdgeInsets.all(8),
//                 color: Colors.blue,
//                 child: SvgPicture.asset(components[index]),
//               ),
//               elevation: 4.0,
//             ),
//             child: Container(
//               child: Column(
//                 children: [
//                   Container(
//                     child: SvgPicture.asset(components[index]),
//                   ),
//                   Text(componentsTitle[index], style: TextStyle(fontWeight: FontWeight.bold),)
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
