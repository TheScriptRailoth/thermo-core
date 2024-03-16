import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'common.dart';


const double gridSize = 20.0;
Offset snapToGrid(Offset position) {
  double x = (position.dx / gridSize).round() * gridSize;
  double y = (position.dy / gridSize).round() * gridSize;
  return Offset(x, y);
}

String? _selectedComponentId;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  ComponentModel? selectedComponent;
  bool isEditingPanelVisible = false;
  bool isSideBarVisible = false;
  String sidebarContent = "Home";

  void _toggleEditPanel() {
    setState(() {
      isEditingPanelVisible = !isEditingPanelVisible;
    });
  }

  void _toggleSideBar(){
    setState(() {
      isSideBarVisible=!isSideBarVisible;
    });
  }

  Widget _getSidebarContent() {
    switch (sidebarContent) {
      case "Home":
        return Text("Home Content");
      case "Settings":
        return Text("Settings Content");
    // Add more cases as needed
      default:
        return Text("Content Not Found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modeling Software"),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_open_sharp),
            onPressed: _toggleEditPanel,
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isSideBarVisible = true;
                          sidebarContent = "Home";
                        });
                      },
                      icon: Icon(CupertinoIcons.home, size: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isSideBarVisible = true;
                          sidebarContent = "Settings";
                        });
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
                child: _getSidebarContent(),
              ),
              SizedBox(width: 20),
              Expanded(
                child: RankineCycleCanvas(
                  onComponentSelected: (id) {
                    setState(() {
                      _selectedComponentId = id;
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



