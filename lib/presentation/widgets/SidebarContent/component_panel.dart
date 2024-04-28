import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../pages/home/common.dart';
class ComponentSidebar extends StatelessWidget {
  final List<String> components = [
    'lib/presentation/assets/turbine_icon.svg',
    'lib/presentation/assets/boiler_icon.svg',
    'lib/presentation/assets/precipitator_icon.svg',
    'lib/presentation/assets/water_pump_icon.svg',
  ];
  final List<String> componentsTitle = ['Turbine', "Boiler", "Condenser", "Pump"];
  final String? selectedComponentId;

  ComponentModel createComponent(String type) {
    switch (type) {
      case 'Turbine':
        return Turbine(id: UniqueKey().toString(), position: Offset.zero);
      case 'Boiler':
        return Boiler(id: UniqueKey().toString(), position: Offset.zero);
      case 'Pump':
        return Pump(id: UniqueKey().toString(), position: Offset.zero);
      case 'Condenser':
        return Precipitator(id: UniqueKey().toString(), position: Offset.zero);
      default:
        throw Exception('Unknown component type: $type');
    }
  }

  ComponentSidebar({Key? key, this.selectedComponentId}) : super(key: key);
  @override
  Widget build(BuildContext context){
    void doNothing(ComponentModel component){}
    return Container(
      width: 300,
      color: Colors.grey[200],
      child: Column(
        children: [
          Flexible(
            child: GridView.builder(
              itemCount: components.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                ComponentModel componentModel = createComponent(componentsTitle[index]);
                return Draggable<DraggableComponentData>(
                  data: DraggableComponentData(createComponent(componentsTitle[index]), isNew: true),
                  feedback: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 4.0,
                    child: ComponentWidget(
                      component: componentModel,
                      onSelect: doNothing,
                      onDelete: doNothing, onConnectionStart: (ComponentModel , Offset , String ) {  }, onConnectionUpdate: (Offset ) {  }, onConnectionEnd: () {  },
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: (){},
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(components[index], width: 100, height: 100)
                            ),
                          ),
                        ),
                        Text(componentsTitle[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20,),
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