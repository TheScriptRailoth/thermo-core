import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'common.dart';

class PropertyEditWindow extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(DragUpdateDetails) onDrag;
  int? stage;
  ComponentModel inletComponent;
  ComponentModel outletComponent;

  PropertyEditWindow({
    super.key,
    required this.onClose,
    required this.onDrag,
    required this.stage,
    required this.inletComponent,
    required this.outletComponent,
  });

  @override
  State<PropertyEditWindow> createState() => _PropertyEditWindowState();
}

class _PropertyEditWindowState extends State<PropertyEditWindow> {
  var result;
  TextEditingController _pressureController = TextEditingController();
  TextEditingController _tempController = TextEditingController();
  TextEditingController _enthalapyController = TextEditingController();
  TextEditingController _entropyController = TextEditingController();

  @override
  void initState() {

    print(widget.inletComponent.imagePath);
    super.initState();
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

  void fetchProperties() async {
    String pressure = _pressureController.text;
    String temperature = _tempController.text;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'P_boiler': double.parse(pressure),
          'T_turbine_inlet': double.parse(temperature),
          'P_condenser': 50.0,
          'eta_turbine': 1.0,
          'eta_pump': 1.0,
        }),
      );

      if (response.statusCode == 200) {
        result = jsonDecode(response.body);
        print(result);
      } else {
        throw Exception('Failed to load properties with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    print(result["Stage1"]["Enthalpy"]);
  }

  @override
  Widget build(BuildContext context) {

    void updateData(){
      setState(() {
        _enthalapyController.text = result['Stage1']['Enthalpy'].toString();
      });
    }

    bool validateInput(String pressure, String temperature) {
      try {
        final double p = double.parse(pressure);
        final double t = double.parse(temperature);
        return p > 0 && t > 0;
      } catch (e) {
        return false;
      }
    }
    return Container(
      width: 500,
      height: 500,
      child: Scaffold(
        backgroundColor: Colors.grey.withOpacity(0.2),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children:[
            GestureDetector(
              onPanUpdate: widget.onDrag,
              child: AppBar(
                title: Text("Properties", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  child: Center(
                      child: SvgPicture.asset(
                          widget.inletComponent.imagePath.toString(),
                        fit: BoxFit.fill,
                      ),
                  ),
                ),
                LongArrowWidget(),
                Container(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: SvgPicture.asset(
                      widget.outletComponent.imagePath,fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 3,),
            Text("Stage : " +widget.stage.toString(), style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),),
            SizedBox(height: 5,),
            Container(
              height: 5,
              color: Colors.grey,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Pressure(P) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Temperature(T) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Entropy(s) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Enthalapy(h) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Pressure(x) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Specific Volume(v) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Work Output : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height:25,
                                  width: 100,
                                  child: Center(
                                    child: TextField(
                                      controller: _pressureController,
                                      cursorHeight: 18,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(" Bar" , style: TextStyle(color: Colors.black, fontSize: 16),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Container(
                                  height:25,
                                  width: 100,
                                  child: TextField(
                                    controller: _tempController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Text(" \u00B0C" , style: TextStyle(color: Colors.black, fontSize: 16),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Container(
                                  height : 25,
                                  width: 100,
                                  child: TextField(
                                    controller : _entropyController
                        
                                  ),
                                ),
                                Text(" J/k" , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text("6546 J" , style: TextStyle(color: Colors.black, fontSize: 16,),),
                            SizedBox(height: 10,),
                            Text("765 " , style: TextStyle(color: Colors.black, fontSize: 16,),),
                            SizedBox(height: 10,),
                            Text("6546" , style: TextStyle(color: Colors.black, fontSize: 16,),),
                            SizedBox(height:10,),
                            Text("6546" , style: TextStyle(color: Colors.black, fontSize: 16,),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding( padding: EdgeInsets.symmetric(vertical: 10),child: ElevatedButton(onPressed: (){
                fetchProperties();
            }, child: Text("Save", style: TextStyle(color: Colors.black),)))
          ],
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;

    // Draw the line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Smaller arrowhead
    const arrowSize = 6.0; // Smaller size for the arrowhead
    // Extend the arrowhead to the very end of the available width
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width - arrowSize, size.height / 2 - arrowSize), paint);
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width - arrowSize, size.height / 2 + arrowSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class LongArrowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(40, 20),
      painter: ArrowPainter(),
    );
  }
}
