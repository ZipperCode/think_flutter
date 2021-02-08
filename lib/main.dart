import 'package:flutter/material.dart';

import 'widget/toast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.red),
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: 100,
                  height: 50,
                  child: Center(child: Text("Click")),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              print("Overlay.of() ${Overlay.of(context)}");
              showToast(context: ctx, message: "hahahah");
            },
          ),
        ),
      ),
    );
  }
}
