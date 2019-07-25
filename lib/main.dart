import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Stop Watch'),
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

  Stopwatch _stopwatch = Stopwatch();
  Timer _timer;

  final GlobalKey<AnimatedCircularChartState> _chartKey =
  new GlobalKey<AnimatedCircularChartState>();

  final _chartSize = const Size(250.0, 250.0);
  Color labelColor = Colors.blue;

  String elapsedTime ='';

  List<CircularStackEntry> _generateChartData(int min, int second) {
    double temp = second * 0.6;
    double adjustedSeconds = second + temp;

    double tempmin = min * 0.6;
    double adjustedMinutes = min + tempmin;

    Color dialColor = Colors.blue;

    labelColor = dialColor;

    List<CircularStackEntry> data = [
      new CircularStackEntry(
          [new CircularSegmentEntry(adjustedSeconds, dialColor)])
    ];

    if (min > 0) {
      labelColor = Colors.green;
      data.removeAt(0);
      data.add(new CircularStackEntry(
          [new CircularSegmentEntry(adjustedSeconds, dialColor)]));
      data.add(new CircularStackEntry(
          [new CircularSegmentEntry(adjustedMinutes, Colors.green)]));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _labelStyle = Theme
        .of(context)
        .textTheme
        .title
        .merge(new TextStyle(color: labelColor));
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
              child: new AnimatedCircularChart(
                key: _chartKey,
                size: _chartSize,
                initialChartData: _generateChartData(0, 0),
                chartType: CircularChartType.Radial,
                edgeStyle: SegmentEdgeStyle.round,
                percentageValues: true,
                holeLabel: elapsedTime,
                labelStyle: _labelStyle,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: startWatch,
                  child: Icon(Icons.play_arrow),
                ),
                SizedBox(width: 20.0),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: stopWatch,
                  child: Icon(Icons.stop),
                ),
                SizedBox(width: 20.0),
                FloatingActionButton(
                  backgroundColor: Colors.blue,
                  onPressed: resetWatch,
                  child: Icon(Icons.refresh),
                ),

              ],
            ),
          ],
        ),
      ),

    );
  }
  startWatch(){
    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
  }

  stopWatch(){
    _stopwatch.stop();
    setTime();
  }

  resetWatch(){
    _stopwatch.reset();
    setTime();
  }
  setTime(){
    var timeSoFar = _stopwatch.elapsedMicroseconds;
    setState(() {
      elapsedTime = transFormMilliSeconds(timeSoFar);
    });
  }

  updateTime(Timer timer){
    if (_stopwatch.isRunning) {
      var milliseconds = _stopwatch.elapsedMilliseconds;
      int hundreds = (milliseconds / 10).truncate();
      int seconds = (hundreds / 100).truncate();
      int minutes = (seconds / 60).truncate();
      setState(() {
        elapsedTime = transFormMilliSeconds(_stopwatch.elapsedMilliseconds);
        if (seconds > 59) {
          seconds = seconds - (59 * minutes);
          seconds = seconds - minutes;
        }
        List<CircularStackEntry> data = _generateChartData(minutes, seconds);
        _chartKey.currentState.updateData(data);
      });
    }
  }
  transFormMilliSeconds(int milliseconds){
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minuteStr = (minutes % 60).toString().padLeft(2,'0');
    String secondStr = (seconds % 60).toString().padLeft(2,'0');
    String hundredStr = (hundreds % 100).toString().padLeft(2,'0');

    return "$minuteStr:$secondStr:$hundredStr";
  }
}
