import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Wrap the Container with Expanded widget
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle, boxShadow: [
          BoxShadow(offset: Offset(10, 10), color: Colors.black38, blurRadius: 15),
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.timer, size: 60, color: Colors.grey.shade800),
            // if (_training_set_list[_menu_index]['is_completed']) ...{Text(_training_set_list[_menu_index]['time'], style: TextStyle(fontSize: 40, color: Colors.grey.shade900))} else ...{Text(timeString, style: TextStyle(fontSize: 40, color: Colors.grey.shade900))}
          ],
        ),
      ),
    );
  }
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: MyHomePage.name,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case MyHomePage.name:
            return FadeInPageRoute(page: const MyHomePage());
          case EmptyScaffold.name:
            return FadeInPageRoute(page: const EmptyScaffold());
        }
      },
    );
  }
}

class FadeInPageRoute extends PageRouteBuilder {
  FadeInPageRoute({required Widget page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: Curves.easeInCubic),
              ),
              child: page,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 1000),
        );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  static const name = '/';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: const [
              Text('Timer-driven Clock'),
              Expanded(
                flex: 9,
                child: TimerBuilder(),
              ),
              Spacer(flex: 1),
              Divider(thickness: 6),
              Spacer(flex: 2),
              Text('Ticker-driven Clock'),
              Expanded(
                flex: 9,
                child: TickerBuilder(),
              ),
            ],
          ),
        ),
      ),
      // timerはRouteがpushされても後ろで動き続ける
      // tickerは自動で止まり、元のRouteに戻れば再開してくれる
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: Transform.scale(
          scale: 3.0,
          child: const Icon(Icons.arrow_right_rounded),
        ),
        onPressed: () => Navigator.pushNamed(context, EmptyScaffold.name),
      ),
    );
  }
}

class EmptyScaffold extends StatelessWidget {
  const EmptyScaffold({Key? key}) : super(key: key);

  static const name = '/empty';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text('Timerはこの状態でも動き続けるけど Tickerは自動で一時ミュートしてくれる'),
      ),
    );
  }
}

// Builder
class TimerBuilder extends StatefulWidget {
  const TimerBuilder({Key? key}) : super(key: key);

  @override
  _TimerBuilderState createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  late DateTime _time;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // 1秒ごとにprint
      // if (timer.tick % 10 == 0) print('timer');
      setState(() {
        _time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConsolidatedClock(time: _time);
  }
}

class TickerBuilder extends StatefulWidget {
  const TickerBuilder({Key? key}) : super(key: key);

  @override
  _TickerBuilderState createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _ticker = createTicker((elapsed) {
      // 1秒ごとにprint
      // if ((elapsed.inMilliseconds) % 1000 == 0) print('ticker');
      setState(() {
        _time = DateTime.now();
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConsolidatedClock(time: _time);
  }
}

// clock
class ConsolidatedClock extends StatelessWidget {
  final DateTime time;

  const ConsolidatedClock({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // horizontalは真ん中に配置、verticalは上から120に配置
        Positioned.fill(
          top: 120,
          child: DigitalClockRenderer(
            time: time,
            digitWidth: 12,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 真ん中に配置
        Positioned.fill(
          child: AnalogClockRenderer(time: time),
        ),
      ],
    );
  }
}

// digital clock
class DigitalClockRenderer extends StatelessWidget {
  final DateTime time;
  final double digitWidth;
  final TextStyle? style;

  const DigitalClockRenderer({
    Key? key,
    required this.time,
    this.digitWidth = 12.0,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 数字一桁ずつ、横幅ありのContainerに入れないと文字の大きさによってブレが生じる
            TimeContainer(
              time: time.hour,
              digits: 2,
              digitWidth: digitWidth,
              suffix: ':',
              style: style,
            ),
            TimeContainer(
              time: time.minute,
              digits: 2,
              digitWidth: digitWidth,
              suffix: ':',
              style: style,
            ),
            TimeContainer(
              time: time.second,
              digits: 2,
              digitWidth: digitWidth,
              style: style,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeContainer(
              time: time.millisecond,
              digits: 3,
              digitWidth: digitWidth,
              style: style,
            ),
          ],
        ),
      ],
    );
  }
}

class TimeContainer extends StatelessWidget {
  final int time;
  final int digits;
  final double digitWidth;
  final String? suffix;
  final TextStyle? style;

  const TimeContainer({
    Key? key,
    required this.time,
    required this.digits,
    this.digitWidth = 12.0,
    this.suffix,
    this.style,
  }) : super(key: key);

  String get timeText => time.toString().padLeft(digits, '0');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < digits; i++) ...[
          Container(
            alignment: Alignment.center,
            width: digitWidth,
            child: Text(
              timeText[i],
              style: style,
            ),
          ),
          if (i == digits - 1)
            Container(
              alignment: Alignment.center,
              child: Text(
                suffix ?? '',
                style: style,
              ),
            ),
        ],
      ],
    );
  }
}

// analog clock
class AnalogClockRenderer extends StatelessWidget {
  final DateTime time;
  final double radius;
  final Color plateColor;
  final Color dialColor;
  final Color secondColor;
  final Color minuteColor;
  final Color hourColor;

  const AnalogClockRenderer({
    Key? key,
    required this.time,
    this.radius = 120.0,
    this.plateColor = Colors.black,
    this.dialColor = Colors.white,
    this.secondColor = Colors.red,
    this.minuteColor = Colors.grey,
    this.hourColor = Colors.grey,
  }) : super(key: key);

  int get secondsInMillisecond => time.second * 1000 + time.millisecond;
  int get minutesInSecond => time.minute * 60 + time.second;
  int get hoursInMinute => (time.hour % 12) * 60 + time.minute;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 60; i++)
            ClockMarker(
              index: i,
              radius: radius,
              markerWidth: 1,
              markerHeight: 12,
              fontSize: 18,
            ),
          // 秒針
          ClockHand(
            // 2π が半径1とした円周なので π は180度
            angle: (2 * pi) * (secondsInMillisecond / (60 * 1000)),
            thickness: 1,
            length: 140,
            color: Colors.pink,
          ),
          // 分針
          ClockHand(
            angle: (2 * pi) * (minutesInSecond / (60 * 60)),
            thickness: 6,
            length: 120,
            color: Colors.white70,
            shadowColor: Colors.amber,
          ),
          // 時針
          ClockHand(
            angle: (2 * pi) * (hoursInMinute / (60 * 12)),
            thickness: 8,
            length: 82,
            color: Colors.white70,
            shadowColor: Colors.amber,
          ),
          const ClockCenterCircle(
            size: 27,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }
}

class ClockMarker extends StatelessWidget {
  final int index;
  final int stops;
  final double radius;
  final double markerWidth;
  final double markerHeight;
  final Color markerColor;
  final double fontSize;
  final Color fontColor;
  final int representativeSplit;
  final int maxRepresentative;

  const ClockMarker({
    Key? key,
    required this.index,
    this.stops = 60,
    required this.radius,
    required this.markerWidth,
    required this.markerHeight,
    this.markerColor = Colors.white54,
    required this.fontSize,
    this.fontColor = Colors.white,
    this.representativeSplit = 12,
    this.maxRepresentative = 12,
  })  : assert(maxRepresentative % representativeSplit == 0),
        assert(maxRepresentative >= representativeSplit),
        assert(stops % maxRepresentative == 0),
        assert(stops >= maxRepresentative),
        super(key: key);

  // マーカーではなく、数字として描画する部分かどうかの判別
  bool get isRepresentative => index % (stops / representativeSplit) == 0;
  // 代表数字のテキスト
  String get representativeText {
    final index = this.index == 0 ? stops : this.index;
    return (maxRepresentative * (index / stops)).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        // 回転軸はContainerの中央にあるので、必ず回転してから移動
        ..rotateZ(2.0 * pi * (index / stops))
        // 0などintで渡してもdoubleに変換されずエラーが出るので注意
        ..translate(0.0, -radius),
      child: !isRepresentative
          ? Container(
              width: markerWidth,
              height: markerHeight,
              color: markerColor,
            )
          : Container(
              width: fontSize * 2,
              alignment: Alignment.center,
              // 数字が読めるように上記Transformの回転を相殺する
              transform: Matrix4.identity()..rotateZ(-2.0 * pi * (index / stops)),
              transformAlignment: Alignment.center,
              child: Text(
                representativeText,
                style: TextStyle(
                  color: fontColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

class ClockHand extends StatelessWidget {
  final double angle;
  final double thickness;
  final double length;
  final Color color;
  final Color? shadowColor;

  const ClockHand({
    Key? key,
    required this.angle,
    required this.thickness,
    required this.length,
    required this.color,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..translate(0.0, -length / 2)
        ..rotateZ(angle),
      child: Container(
        width: thickness,
        height: length,
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            if (shadowColor != null)
              BoxShadow(
                color: shadowColor!,
                blurRadius: 12,
                spreadRadius: 1,
              )
          ],
          borderRadius: BorderRadius.circular(thickness),
        ),
      ),
    );
  }
}

class ClockCenterCircle extends StatelessWidget {
  final double size;
  final Color color;

  const ClockCenterCircle({
    Key? key,
    this.size = 30,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.white24,
          width: size * 0.15,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
