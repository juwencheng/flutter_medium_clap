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

enum ScoreWidgetStatus { HIDDEN, BECOMING_VISIBLE, BECOMING_INVISIBLE }

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  Timer holdTimer;
  Timer releaseTimer;
  ScoreWidgetStatus _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
  final duration = new Duration(milliseconds: 300);
  AnimationController scoreInAnimationController;
  AnimationController scoreOutAnimationController;
  Animation scoreOutPositionAnimationController;
  AnimationController scoreSizeAnimationController;

  @override
  void initState() {
    super.initState();
    // score 显示的动画
    scoreInAnimationController =
        new AnimationController(vsync: this, duration: duration);
    scoreInAnimationController.addListener(() {
      setState(() {});
    });

    // score消失的动画
    scoreOutAnimationController =
        AnimationController(vsync: this, duration: duration);
    scoreOutPositionAnimationController = new Tween(begin: 100.0, end: 150.0)
        .animate(new CurvedAnimation(
            parent: scoreOutAnimationController, curve: Curves.easeOut));
    scoreOutPositionAnimationController.addListener(() {
      setState(() {});
    });
    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
      setState(() {});
    });

    // score 大小动画
    scoreSizeAnimationController =
        new AnimationController(vsync: this, duration: duration);
    scoreSizeAnimationController.addListener(() {
      setState(() {});
    });
    scoreSizeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        scoreSizeAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    holdTimer?.cancel();
    releaseTimer?.cancel();
    scoreInAnimationController.dispose();
    scoreOutAnimationController.dispose();
    scoreSizeAnimationController.dispose();
  }

  void _incrementCounter(Timer timer) {
    scoreSizeAnimationController.forward(from: 0);

    setState(() {
      _counter++;
    });
  }

  void onTapDown(TapDownDetails tap) {
    releaseTimer?.cancel();
    if (_scoreWidgetStatus == ScoreWidgetStatus.HIDDEN) {
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
      scoreInAnimationController.forward(from: 0);
    } else if (_scoreWidgetStatus == ScoreWidgetStatus.BECOMING_INVISIBLE) {
      scoreOutAnimationController.value = 1;
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
      scoreInAnimationController.forward(from: 0);
    }

    _incrementCounter(null);
    holdTimer = new Timer.periodic(duration, _incrementCounter);
  }

  void onTapUp(TapUpDetails tap) {
    releaseTimer = Timer(duration, () {
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
      scoreOutAnimationController.forward(from: 0);
    });
    holdTimer?.cancel();
  }

  Widget _buildClapButton() {
    var extraSize = scoreSizeAnimationController.value * 10;
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 56 + extraSize,
        height: 56 + extraSize,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          shape: CircleBorder(side: BorderSide(color: Colors.blue, width: 2)),
        ),
        child: Icon(
          Icons.add,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildScoreButton() {
    var scorePosition = 0.0;
    var scoreOpacity = 0.0;
    var extraSize = scoreSizeAnimationController.value * 10;
    switch (_scoreWidgetStatus) {
      case ScoreWidgetStatus.BECOMING_VISIBLE:
        scorePosition = scoreInAnimationController.value * 100;
        scoreOpacity = scoreInAnimationController.value;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scorePosition = scoreOutPositionAnimationController.value;
        scoreOpacity = 1 - scoreOutAnimationController.value;
        break;
      default:
        break;
    }
    return Positioned(
      bottom: scorePosition,
      width: 56 + extraSize,
      height: 56 + extraSize,
      child: Opacity(
        opacity: scoreOpacity,
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration:
                ShapeDecoration(color: Colors.blue, shape: CircleBorder()
//              borderRadius: BorderRadius.circular(30),
                    ),
            child: Center(
                child: Text(
              "+" + _counter.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var extraSize = scoreSizeAnimationController.value * 10;
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
        padding: EdgeInsets.only(right: 16 - extraSize / 2),
        child: Stack(
          alignment: FractionalOffset.center,
          overflow: Overflow.visible,
          children: <Widget>[
            // 这里有个知识点，stack的顺序
            _buildScoreButton(),
            _buildClapButton(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
