import 'package:day_calendar_flutter/day_calendar_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ModularState<HomePage, HomeController> {
  @override
  HomeController get controller => super.controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("day_calendar_flutter"),
        ),
        body: Column(
          children: <Widget>[
            DayCalendarFlutter(
              currentDate: DateTime(2024, 2, 28),
              initialHour: 06,
              finalHour: 22,
              onDateChange: (i) {
                print(i);
              },
              events: [
                new Event(
                    color: Colors.cyan,
                    initialDate: DateTime(2020, 05, 26, 13, 00),
                    finalDate: DateTime(2020, 05, 26, 13, 30),
                    title: "Reunião",
                    eventTitleStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    showHours: true,
                    allDay: true,
                    onEventTap: (event) {}),
              ],
              onTap: (date) {
                print(DateFormat('HH:mm').format(date));
              },
            ),
          ],
        ));
  }
}
