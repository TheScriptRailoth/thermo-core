import 'package:edurank/presentation/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThermodynamicObject {
  final String name;
  final Color color;
  final String icon;
  bool isSelected;

  ThermodynamicObject({required this.name, required this.color, required this.icon,this.isSelected = false});
}

class ObjectPanel extends StatefulWidget {
  const ObjectPanel({Key? key}) : super(key: key);

  @override
  _ObjectPanelState createState() => _ObjectPanelState();
}

class _ObjectPanelState extends State<ObjectPanel> {
  late List<ThermodynamicObject> objects;

  @override
  void initState() {
    super.initState();
    // Initialize the list of objects
    objects = [
      ThermodynamicObject(name: 'Turbine', color: Colors.transparent, icon: 'lib/presentation/assets/turbine_icon.svg'),
      ThermodynamicObject(name: 'Pump', color: Colors.blue, icon: 'lib/presentation/assets/turbine_icon.svg'),
      ThermodynamicObject(name: 'Precepetator', color: Colors.lightBlueAccent, icon: 'lib/presentation/assets/turbine_icon.svg')
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Visibility(
      visible: SideBar.isPanelOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: SideBar.isPanelOpen?200:0,
          curve: Curves.easeInOut,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: 200.w,
            color: Colors.grey.withOpacity(0.2),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(objects.length, (index) {
                  final object = objects[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: GestureDetector(
                      onTap: () {
                        // Deselect all objects
                        setState(() {
                          objects.forEach((element) {
                            element.isSelected = false;
                          });
                          // Toggle the selected state of the tapped object
                          object.isSelected = true;
                        });
                      },
                      child: Container(
                          height: 100.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: object.color,
                            border: Border.all(
                              color: object.isSelected ? Colors.lightBlueAccent : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: SvgPicture.asset(
                            object.icon,
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        )
    );
    return Container(
      height: MediaQuery.of(context).size.height,
      width: 200.w,
      color: Colors.grey.withOpacity(0.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(objects.length, (index) {
            final object = objects[index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: GestureDetector(
                onTap: () {
                  // Deselect all objects
                  setState(() {
                    objects.forEach((element) {
                      element.isSelected = false;
                    });
                    // Toggle the selected state of the tapped object
                    object.isSelected = true;
                  });
                },
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: object.color,
                    border: Border.all(
                      color: object.isSelected ? Colors.lightBlueAccent : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: SvgPicture.asset(
                    object.icon,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                  )
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
