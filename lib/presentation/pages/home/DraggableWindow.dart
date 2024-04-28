import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../widgets/arrow_widget.dart';
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
  late int updatedStage;
  TextEditingController _pController = TextEditingController();
  TextEditingController _tController = TextEditingController();
  TextEditingController _hController = TextEditingController();
  TextEditingController _sController = TextEditingController();
  TextEditingController _vController = TextEditingController();
  TextEditingController _xController = TextEditingController();

 int xyz=0;
  @override
  void initState() {
    super.initState();
    _tController = TextEditingController();
    _pController = TextEditingController();
    _hController = TextEditingController();
    _sController = TextEditingController();
    _xController = TextEditingController();
    _vController = TextEditingController();
  }

  @override
  void dispose() {
    _tController.dispose();
    _hController.dispose();
    _xController.dispose();
    _pController.dispose();
    _sController.dispose();
    _vController.dispose();
    super.dispose();
  }

  String apiUrl = 'http://127.0.0.1:5000/calculate';
  void fetchProperties() async {
    String pressure = _pController.text;
    String temperature = _tController.text;

    Map<String, dynamic> requestData = {
      'p_boiler': double.tryParse(pressure) ?? 0.0,
      'T_boiler': double.tryParse(temperature) ?? 0.0,
      'p_condenser': 50.0,
      'eta_turbine': 1.0,
      'eta_pump': 1.0,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        setState(() {
          result = jsonDecode(response.body);
        });
        print(updatedStage);
        updateData();
      } else {
        throw Exception('Failed to load properties with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void accessState1H() {
    if (result != null) {
      var state1 = result['State 1'];
      if (state1 != null && state1['h'] != 'undefined') {
        var hValue = state1['h'];
        print("The enthalpy (h) of State 1 is: $hValue");
      } else {
        print("The enthalpy (h) of State 1 is undefined or the data is not available.");
      }
    } else {
      print("No result data available.");
    }
  }


  int stageUpdater(){
    print(widget.inletComponent.type);
    print(widget.outletComponent.type);
    int stage=0;
    if(widget.inletComponent.type =='Boiler' && widget.outletComponent.type =='Turbine')
      stage=1;
    else if (widget.inletComponent.type =='Turbine' && widget.outletComponent.type =='Condenser')
      stage=2;
    else if(widget.inletComponent.type =='Condenser' && widget.outletComponent.type =='Pump')
      stage=3;
    else if(widget.inletComponent.type =='Pump' && widget.outletComponent.type =='Boiler')
      stage=4;
    return stage;
  }
  void updateData(){
    setState(() {
      if(updatedStage ==1)
        if (result != null) {
          var state1 = result['State 1'];
          if (state1 != null && state1['h'] != 'undefined') {
            var h = state1['h'];
            var s = state1['s'];
            var hs = state1['hs'];
            var ss = state1['ss'];
            var x = state1['x'];
            var v = state1['v'];

            _hController.text = h.toString();
            _vController.text = v.toString();
            _sController.text = s.toString();
            _xController.text = x.toString();
            _vController.text = v.toString();
          }
        }
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

  // void updateProperties() {
  //   double newPressure = double.parse(_pressureController.text);
  //   double newTemperature = double.parse(_tempController.text);
  //
  //   if (updatedStage == 1) {
  //
  //   } else if (updatedStage == 2) {
  //     // widget.inletComponent.updatePressure(newPressure);  // Condenser pressure
  //     // No need to update temperature for condenser, just an example
  //   }
  //   // Add similar conditions for other stages
  //
  //   // Assuming we need to trigger a rebuild or update the state elsewhere
  //   setState(() {});
  // }


  @override
  Widget build(BuildContext context) {

    updatedStage = stageUpdater();

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
                                      controller: _pController,
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
                                    controller: _tController,
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
                                    controller : _hController

                                  ),
                                ),
                                Text(" J/k" , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            TextField(controller: _sController, style: TextStyle(color: Colors.black, fontSize: 16,),),
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



