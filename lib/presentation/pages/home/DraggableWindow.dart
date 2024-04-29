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
  TextEditingController _hsController = TextEditingController();
  TextEditingController _ssController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tController = TextEditingController();
    _pController = TextEditingController();
    _hController = TextEditingController();
    _sController = TextEditingController();
    _xController = TextEditingController();
    _vController = TextEditingController();
    _hsController = TextEditingController();
    _ssController = TextEditingController();
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

  int stageUpdater(){
    int stage=0;
    if(widget.inletComponent.type =='Boiler' && widget.outletComponent.type =='Turbine')
      stage=1;
    else if (widget.inletComponent.type =='Turbine' && widget.outletComponent.type =='Precipitator')
      stage=2;
    else if(widget.inletComponent.type =='Precipitator' && widget.outletComponent.type =='Pump')
      stage=3;
    else if(widget.inletComponent.type =='Pump' && widget.outletComponent.type =='Boiler')
      stage=4;
    return stage;
  }

  void updateData() {
    print(updatedStage);
    setState(() {
      if (result != null) {
        String stateKey = 'State $updatedStage';
        var currentState = result[stateKey];
        if (currentState != null) {
          _hController.text = currentState['h'].toString().substring(0,9);
          _sController.text = currentState['s'].toString().substring(0,9);
          _hsController.text =currentState['hs'].toString().substring(0,9);
          _ssController.text = currentState['ss'].toString().substring(0,9);
          _xController.text = currentState['x'].toString().substring(0,9);
          _vController.text = currentState['v'].toString().substring(0,9);
        } else {
          _hController.clear();
          _sController.clear();
          _hsController.clear();
          _ssController.clear();
          _xController.clear();
          _vController.clear();
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 20,),
                            Text("Pressure(P) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 20,),
                            Text("Temperature(T) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Entropy(s) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Enthalapy(h) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Dryness Fraction(x) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Specific Volume(v) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("h at Saturated(hs) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("s at Saturated(ss) : " , style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
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
                                  width: 120,
                                  child: Center(
                                    child: TextField(
                                      controller: _pController,
                                      cursorHeight: 18,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      scrollPadding: EdgeInsets.all(20.0),  // Ensures padding within the scroll area
                                      keyboardType: TextInputType.text,  // Ensures the keyboard type is for general text
                                      maxLines: 1,  // Keeps the input to one line
                                      scrollPhysics: BouncingScrollPhysics(),
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
                                  width: 120,
                                  child: Center(
                                    child: TextField(
                                      controller: _tController,
                                      cursorHeight: 18,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(" \u00B0C" , style: TextStyle(color: Colors.black, fontSize: 16),),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 25,
                                  width: 120,
                                  child: TextField(
                                  controller: _sController,
                                  cursorHeight: 18,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                                    fillColor: Colors.transparent,
                                    filled: true,
                                  ),
                                  enabled: false,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  textAlign: TextAlign.center,  // Centers the text
                              ),
                            ),
                                const Text(" " , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Container(
                                  height: 25,
                                  width: 120,
                                  child: TextField(
                                    controller: _hController,
                                    cursorHeight: 18,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                    enabled: false,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    scrollPhysics: const BouncingScrollPhysics(),
                                    textAlign: TextAlign.center,  // Centers the text
                                  ),
                                ),
                                Text(" " , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Container(
                                  height: 25,
                                  width: 120,
                                  child: TextField(
                                    controller: _xController,
                                    cursorHeight: 18,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                    enabled: false,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    scrollPhysics: const BouncingScrollPhysics(),
                                    textAlign: TextAlign.center,  // Centers the text
                                  ),
                                ),
                                Text(" " , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Container(
                                  height: 25,
                                  width: 120,
                                  child: TextField(
                                    controller: _vController,
                                    cursorHeight: 18,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                    enabled: false,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    scrollPhysics: const BouncingScrollPhysics(),
                                    textAlign: TextAlign.center,  // Centers the text
                                  ),
                                ),
                                Text(" " , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
                            SizedBox(height:10,),
                            Row(
                              children: [
                                Container(
                                  height: 25,
                                  width: 120,
                                  child: TextField(
                                    controller: _hsController,
                                    cursorHeight: 18,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                    enabled: false,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    scrollPhysics: const BouncingScrollPhysics(),
                                    textAlign: TextAlign.center,  // Centers the text
                                  ),
                                ),
                                Text(" " , style: TextStyle(color: Colors.black, fontSize: 16,),),
                              ],
                            ),
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



