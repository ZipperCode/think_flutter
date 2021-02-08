import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: App(),
  ));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final List<Widget> list = [
    ChangeWidget1(Colors.red),
    ChangeWidget1(Colors.blue),
  ];

  final List<Widget> list2 = [
    ChangeWidget2(Colors.red),
    ChangeWidget2(Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("statelessWidget"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: list,
            ),
            Text("statefullWidget"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: list2,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _change,
        child: Icon(Icons.undo),
      ),
    );
  }

  void _change() {
    list.insert(0, list.removeLast());
    list2.insert(0, list2.removeLast());
    setState(() {});
  }
}

class ChangeWidget1 extends StatelessWidget {
  final Color _color;

  ChangeWidget1(this._color);

  @override
  Widget build(BuildContext context) {
    print("build color $_color");
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: _color),
    );
  }
}

class ChangeWidget2 extends StatefulWidget {
  final Color _color;

  ChangeWidget2(this._color);

  @override
  _ChangeWidget2State createState() => _ChangeWidget2State();
}

class _ChangeWidget2State extends State<ChangeWidget2> {
  @override
  Widget build(BuildContext context) {
    print("build2 color ${widget._color}");
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: widget._color),
    );
  }
}
