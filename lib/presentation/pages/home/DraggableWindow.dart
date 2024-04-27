import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyEditWindow extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(DragUpdateDetails) onDrag;

  const PropertyEditWindow({
    super.key,
    required this.onClose,
    required this.onDrag,
  });

  @override
  State<PropertyEditWindow> createState() => _PropertyEditWindowState();
}

class _PropertyEditWindowState extends State<PropertyEditWindow> {
  TextEditingController _pressureController = TextEditingController();
  TextEditingController _tempController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempController = TextEditingController();
  }

  @override
  void dispose() {
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    void fetchProperties(String pressure, String temperature) async {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/calculate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'P_boiler': double.parse(pressure),
          'T_turbine_inlet': double.parse(temperature),
          'P_condenser': double.parse("50"),
          'eta_turbine': 1.0,
          'eta_pump': 1.0,
        }),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result);
      } else {
        throw Exception('Failed to load properties with status code: ${response.statusCode}');
      }
    }

    return Container(
      width: 500,
      height: 400,
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
            Container(
              height: 5,
              color: Colors.grey,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                    ),
                    Expanded(
                      child: SingleChildScrollView(
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
                                Text("", style: TextStyle(color: Colors.black, fontSize: 16,),),
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
                    ),
                  ],
                ),
              ),
            ),
            Padding( padding: EdgeInsets.symmetric(vertical: 10),child: ElevatedButton(onPressed: (){
              fetchProperties("1500", "500");
            }, child: Text("Save", style: TextStyle(color: Colors.black),)))
          ],
        ),
      ),
    );
  }
}

