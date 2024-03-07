import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThermodynamicObject {
  final String name;
  final Color color;
  bool isSelected;

  ThermodynamicObject({
    required this.name,
    required this.color,
    this.isSelected = false,
  });
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
      ThermodynamicObject(name: 'Turbine', color: Colors.yellow),
      ThermodynamicObject(name: 'Pump', color: Colors.blue),
      // Add more objects as needed
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                  // Toggle the selected state of the object
                  setState(() {
                    object.isSelected = !object.isSelected;
                  });
                },
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: object.color,
                    border: Border.all(
                      color: object.isSelected ? Colors.black : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      object.name,
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
