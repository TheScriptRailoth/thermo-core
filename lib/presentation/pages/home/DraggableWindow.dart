import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class PropertyEditWindow extends StatelessWidget {
  final VoidCallback onClose;
  final void Function(DragUpdateDetails) onDrag;

  const PropertyEditWindow({super.key, required this.onClose, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children:[
            GestureDetector(
              onPanUpdate: onDrag,
              child: AppBar(
                title: Text("Edit Properties"),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: "Some Input"),
                    ),
                    // More widgets can be added here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
