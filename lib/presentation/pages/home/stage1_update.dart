import 'package:flutter/material.dart';

import 'common.dart';

class TurbineForm extends StatefulWidget {
  final Turbine turbine;

  TurbineForm({Key? key, required this.turbine}) : super(key: key);

  @override
  _TurbineFormState createState() => _TurbineFormState();
}

class _TurbineFormState extends State<TurbineForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pressureController;
  late TextEditingController _temperatureController;
  late TextEditingController _efficiencyController;

  @override
  void initState() {
    super.initState();
    _pressureController = TextEditingController(text: widget.turbine.pressure.toString());
    _temperatureController = TextEditingController(); // Assuming you have a temperature or similar
    _efficiencyController = TextEditingController(text: widget.turbine.efficiency.toString());
  }

  @override
  void dispose() {
    _pressureController.dispose();
    _temperatureController.dispose();
    _efficiencyController.dispose();
    super.dispose();
  }

  void _updateTurbine() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.turbine.pressure = double.parse(_pressureController.text);
        widget.turbine.efficiency = double.parse(_efficiencyController.text);
        // Update other properties similarly
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Turbine')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _pressureController,
              decoration: InputDecoration(labelText: 'Inlet Pressure (bar)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _efficiencyController,
              decoration: InputDecoration(labelText: 'Efficiency (%)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: (){
                _updateTurbine();
                print(widget.turbine.efficiency);
                print(widget.turbine.pressure);
              },
              child: Text('Update Turbine'),
            ),
          ],
        ),
      ),
    );
  }
}
