import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medium Clap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Timer timer;
  final duration = new Duration(milliseconds: 300);

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void _incrementCounter(Timer timer) {
    setState(() {
      _counter++;
    });
  }

  void onTapDown(TapDownDetails tap) {
    _incrementCounter(null);
    timer = new Timer.periodic(duration, _incrementCounter);
  }

  void onTapup(TapUpDetails tap) {
    timer?.cancel();
  }

  Widget _buildClapButton() {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapup,
      child: Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Colors.black38, blurRadius: 4, offset: Offset(1, 1)),
            ]),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildScoreButton() {
    return Positioned(
      bottom: 100,
      width: 56,
      height: 56,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.blue,
              width: 1,
            ),
          ),
          child: Center(
              child: Text(
            "+" + _counter.toString(),
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Stack(
          alignment: FractionalOffset.center,
          overflow: Overflow.visible,
          children: <Widget>[
            _buildClapButton(),
            _buildScoreButton(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
