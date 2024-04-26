import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import '../../widgets/SidebarContent/component_panel.dart';
import 'DraggableWindow.dart';
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
      default:
        return Text("");
    }
  }

  bool showDraggableWindow=false;
  void onTapOnConnection() {
    setState(() {
      showDraggableWindow = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: isSideBarVisible ? 300 : 0,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: isSideBarVisible ? 300 : MediaQuery.of(context).size.width,
                    alignment: Alignment.topLeft,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sidebarContent, style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),),
                              IconButton(onPressed: (){
                                setState(() {
                                  isSideBarVisible=false;
                                });
                              }, icon: const Icon(CupertinoIcons.minus))
                            ],
                          ),
                        ),
                        Expanded(child: _getSidebarContent()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
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
        ],
      ),
    );
  }
}



