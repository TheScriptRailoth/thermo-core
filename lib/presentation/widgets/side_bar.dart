import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();

  static bool isPanelOpen = false;

}

class _SideBarState extends State<SideBar> {

  Color iconColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: 60.w,
      color: const Color(0xff0D0D0D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 10.h,),
          IconButton(
            onPressed: () {
              setState(() {
                // Toggle panel visibility
                SideBar.isPanelOpen = !SideBar.isPanelOpen;
                // Toggle icon color
                iconColor = SideBar.isPanelOpen ? Colors.indigo : Colors.grey;
                print(SideBar.isPanelOpen);
              });
            },
            icon: Icon(
              Icons.menu,
              color: iconColor,
            ),
          ),
          // You can add more widgets for your sidebar content here
        ],
      ),
    );
  }
}
