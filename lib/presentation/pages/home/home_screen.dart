import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import '../../widgets/SidebarContent/component_panel.dart';
import 'common.dart';

const double gridSize = 20.0;
Offset snapToGrid(Offset position) {
  double x = (position.dx / gridSize).round() * gridSize;
  double y = (position.dy / gridSize).round() * gridSize;
  return Offset(x, y);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();

  static String? _selectedComponentId;
}

class _HomeScreenState extends State<HomeScreen> {

  ComponentModel? selectedComponent;
  bool isEditingPanelVisible = false;
  bool isSideBarVisible = false;
  String sidebarContent = "";
  String xyz="";

  void _toggleEditPanel() {
    setState(() {
      isEditingPanelVisible = !isEditingPanelVisible;
    });
  }

  void _toggleSideBar(String contentType){
    setState(() {
      if(sidebarContent!=contentType){
        isSideBarVisible=true;
        sidebarContent=contentType;
        xyz=sidebarContent;
      }else {
        isSideBarVisible = !isSideBarVisible;
        xyz = isSideBarVisible ? contentType : "";
      }
    });
  }

  Widget _getSidebarContent() {
    switch (sidebarContent) {
      case "Devices":
        return ComponentSidebar(selectedComponentId: HomeScreen._selectedComponentId,);
      case "Settings":
        return Container();
    // Add more cases as needed
      default:
        return Text("Content Not Found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Modeling Software"),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.menu_open_sharp),
      //       onPressed: _toggleEditPanel,
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  children: [
                    SizedBox(height: 5,),
                    IconButton(
                      onPressed: () => _toggleSideBar("Devices"),
                      icon: Image.asset("lib/presentation/assets/puzzle.png"),
                      // icon: Icon(CupertinoIcons.home, size: 18),
                    ),
                    SizedBox(height: 5,),
                    IconButton(
                      onPressed: () {
                        _toggleSideBar("Settings");
                      },
                      icon: Icon(CupertinoIcons.settings, size: 18),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSideBarVisible ? 300 : 0,
                child: Column(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(sidebarContent, style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),),
                          IconButton(onPressed: (){
                            setState(() {
                              isSideBarVisible=false;
                            });
                          }, icon: Icon(CupertinoIcons.minus))
                        ],
                      ),
                    ),
                    Expanded(child: _getSidebarContent()),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: RankineCycleCanvas(
                  onComponentSelected: (id) {
                    setState(() {
                      HomeScreen._selectedComponentId = id;
                    });
                  },
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: isEditingPanelVisible ? 0 : -300, // Slide in and out
            top: 0,
            bottom: 0,
            child: Container(
              width: 300,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _toggleEditPanel,
                      ),
                    ),
                    Text(
                      'Edit Component Properties',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Add your form fields or other widgets here
                    Expanded(
                      child: Text("HUHUI"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Perform save operation
                        _toggleEditPanel();
                      },
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



