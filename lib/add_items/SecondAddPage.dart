import 'package:flutter/material.dart';

class SecondAddPage extends StatelessWidget {
  const SecondAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Add new item",
          style: TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 15),
        const Text("Add the {item_type} info"),
        SizedBox(height: 15,),
        // Input data that will depend on the {item_type}
        FilledButton(onPressed: () => {
          print("")
        }, child: const Text("Done"))
      ],
    )));
  }
}
