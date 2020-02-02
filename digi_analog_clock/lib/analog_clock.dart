import 'dart:async';

import 'package:analog_clock/hand_colors.dart';
import 'package:analog_clock/styles.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _condition = '';
  var _location = '';
  Timer _timer;
  // colors for every hour
  final List<Color> colors = [
    HandColors.hourTwelve,
    HandColors.hourOne,
    HandColors.hourTwo,
    HandColors.hourThree,
    HandColors.hourFour,
    HandColors.hourFive,
    HandColors.hourSix,
    HandColors.hourSeven,
    HandColors.hourEight,
    HandColors.hourNine,
    HandColors.hourTen,
    HandColors.hourEleven
  ];

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Colors.red,
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Colors.green,
            backgroundColor: Color(0xFF3C4043),
          );
    final time = DateFormat.Hms().format(DateTime.now());
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            // weather text in bottom
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _generateTemperatureList().map((f) {
                    String minMax = ">>";
                    if (f == widget.model.lowString) minMax = "Mininum";
                    if (f == widget.model.highString) minMax = "Maximum";
                    final bool _isCurrentTemp =
                        f == widget.model.temperatureString;
                    if (_isCurrentTemp) minMax = "now";
                    FontWeight _fontWeight =
                        _isCurrentTemp ? FontWeight.bold : FontWeight.normal;
                    return Column(
                      children: <Widget>[
                        Text(f ?? "",
                            style: infoTextStyle(
                                color: _isCurrentTemp
                                    ? customTheme.primaryColor
                                    : null,
                                fontSize: 18,
                                fontWeight: _fontWeight)),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: _isCurrentTemp ? 10 : 0, vertical: 1),
                          decoration: BoxDecoration(
                              color: _isCurrentTemp
                                  ? customTheme.primaryColor
                                  : null,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            minMax,
                            style: infoTextStyle(
                                color: _isCurrentTemp ? Colors.white : null,
                                fontWeight: _fontWeight),
                          ),
                        ),
                      ],
                    );
                  }).toList()),
            ),
            // clock hand for second
            DrawnHand(
              color: lightenColor(
                  colors[TimeOfDay.fromDateTime(_now).hourOfPeriod],
                  _now.second / 150),
              size: 1,
              angleRadians: _now.second * radiansPerTick,
              time: _now.second.toString(),
            ),
            //  clock hand for minute
            DrawnHand(
                color: lightenColor(
                    colors[TimeOfDay.fromDateTime(_now).hourOfPeriod], .2),
                size: 0.7,
                angleRadians: _now.minute * radiansPerTick,
                time: _now.minute.toString()),
            // clock hand for hour
            DrawnHand(
                color: colors[TimeOfDay.fromDateTime(_now).hourOfPeriod],
                size: 0.5,
                angleRadians: _now.hour * radiansPerHour +
                    (_now.minute / 60) * radiansPerHour,
                time: widget.model.is24HourFormat
                    ? _now.hour.toString()
                    : TimeOfDay.fromDateTime(_now).hourOfPeriod == 0
                        ? "12"
                        : TimeOfDay.fromDateTime(_now).hourOfPeriod.toString()),
            // top text for location and condition
            Positioned(
              top: 3,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _location,
                    style: infoTextStyle(fontSize: 18),
                  ),
                  Text(
                    _condition,
                    style: infoTextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            // center of clock hands
            Center(
              child: centerContainer(
                  width: 10,
                  height: 10,
                  color: Colors.white,
                  child: Center(
                    child: centerContainer(
                        width: 6, height: 6, color: customTheme.primaryColor),
                  )),
            )
          ],
        ),
      ),
    );
  }

  /// builds a circuler design for creating center design of hands
  Container centerContainer(
      {double width, double height, Color color, Widget child}) {
    return Container(
      width: width,
      height: height,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
      child: child,
    );
  }

  /// generates a list of text for showing temprature information at the bottom of the clock
  List<String> _generateTemperatureList() {
    final List<String> tempList = List<String>()
      ..length = (widget.model.high - widget.model.low + 1).toInt();
    tempList.first = widget.model.lowString;
    tempList.last = widget.model.highString;
    int currentTempIndex =
        (widget.model.temperature - widget.model.low).toInt();
    tempList[currentTempIndex] = widget.model.temperatureString;
    return tempList;
  }

  /// lighten the color of other hands with respect to hour hand
  Color lightenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
