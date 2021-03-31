import 'package:date_util/date_util.dart';
import 'package:day_calendar_flutter/src/day_calendar_controller.dart';
import 'package:day_calendar_flutter/src/utils/models/event.dart';
import 'package:day_calendar_flutter/src/utils/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

class DayCalendarFlutter extends StatefulWidget {
  ///Set initial hour of the timeline
  final int initialHour;

  ///Set final hour of the timeline
  final int finalHour;

  ///Current date
  DateTime currentDate;

  ///Function for get on taped date
  final OnTap onTap;

  ///List of Events
  List<Event> events = [];

  ///Color of day in header
  final Color colorOfHeader;

  ///color of selected hour/event
  final Color selectedColor;

  ///color for lines and text of timeline
  final Color colorTimeLine;

  ///event for change date
  final OnDateChange onDateChange;

  ///bolean for show header or no
  final bool showHeader;

  ///a custom header widget
  final Widget customHeader;

  ///set if page can change
  final bool changePage;

  DayCalendarFlutter({
    Key key,
    this.finalHour,
    this.initialHour,
    this.currentDate,
    this.onTap,
    this.colorOfHeader,
    this.colorTimeLine,
    this.selectedColor,
    this.onDateChange,
    this.showHeader = true,
    this.customHeader,
    this.changePage,
    @required this.events,
  }) : super(key: key);
  @override
  _DayCalendarFlutterState createState() => _DayCalendarFlutterState();
}

class _DayCalendarFlutterState extends State<DayCalendarFlutter> {
  PageController pageController;

  DayCalendarController controller = new DayCalendarController();

  int lengthMonth = 31;

  @override
  void initState() {
    super.initState();
    controller.generateListDates(
      initialHour: widget.initialHour,
      finalHour: widget.finalHour,
      currentDate: widget.currentDate,
    );
    pageController = PageController(initialPage: widget.currentDate.day);
    widget.events = controller.validateEventsDate(widget.events);
    lengthMonth =
        DateTime(widget.currentDate.year, widget.currentDate.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        itemCount: widget.changePage == null ||
                (widget.changePage != null && widget.changePage)
            ? DateTime(widget.currentDate.year, widget.currentDate.month + 1, 0)
                        .day ==
                    29
                ? 366
                : 365
            : 1,
        controller: pageController,
        onPageChanged: (i) {
          var oldMonth = widget.currentDate.month;
          setState(() {
            if (double.parse(i.toString()) <
                double.parse(pageController.page.toString())) {
              widget.currentDate = DateTime(
                widget.currentDate.year,
                widget.currentDate.month,
                widget.currentDate.day - 1,
              );
            }

            if (double.parse(i.toString()) >
                double.parse(pageController.page.toString())) {
              widget.currentDate = DateTime(
                widget.currentDate.year,
                widget.currentDate.month,
                widget.currentDate.day + 1,
              );
            }
          });

          if (oldMonth != widget.currentDate.month) {
            setState(() {
              lengthMonth = DateTime(
                      widget.currentDate.year, widget.currentDate.month + 1, 0)
                  .day;
            });
          }

          if (widget.onDateChange != null) {
            widget.onDateChange(widget.currentDate);
          }
        },
        itemBuilder: (_, __) => Container(
          child: Observer(builder: (_) {
            return Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: widget.showHeader != null && widget.showHeader
                        ? 120.0
                        : 0.0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Column(
                              children: _buildListHours(),
                            ),
                            buildEvents(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                widget.showHeader == null ||
                        (widget.showHeader != null && widget.showHeader)
                    ? widget.customHeader == null
                        ? buildHeader()
                        : SizedBox.shrink()
                    : SizedBox.shrink(),
              ],
            );
          }),
        ),
      ),
    );
  }

  buildHeader() {
    return widget.showHeader != null && widget.showHeader
        ? widget.customHeader == null
            ? Container(
                height: 100,
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: widget.currentDate.day !=
                                          DateTime.now().day
                                      ? Colors.grey[400]
                                      : widget.colorOfHeader == null
                                          ? Colors.blueAccent
                                          : widget.colorOfHeader,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                DateFormat('dd').format(widget.currentDate),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('EE', 'pt-br')
                                  .format(widget.currentDate),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            : widget.customHeader
        : SizedBox.shrink();
  }

  double _generatePositionCard(DateTime date, {bool isAllDay = false}) {
    var index = controller.listHour.indexWhere(
      (t) => t['date'].hour == date.hour && t['date'].minute == date.minute,
    );

    if (isAllDay) {
      index = 0;
    }

    return double.parse(((index * 1.61) + 3).toString());
  }

  double _generateHeightCard(DateTime date, {bool isAllDay = false}) {
    var index = controller.listHour.indexWhere(
      (t) => t['date'].hour == date.hour && t['date'].minute == date.minute,
    );

    if (isAllDay) {
      index = controller.listHour.length;
    }

    return double.parse(((index * 1.61) + 3).toString());
  }

  buildEvents() {
    List<Widget> children = [];

    widget.events.forEach((ev) {
      if (ev.initialDate.month == widget.currentDate.month &&
          ev.initialDate.day == widget.currentDate.day) {
        children.add(createWidget(ev));
      }
    });

    return SizedBox(
      height: controller.listHour.length * 1.63,
      child: Stack(
        children: children,
      ),
    );
  }

  Map calculateWidth(Event event, List<Event> eventos) {
    List<Event> list = [];
    double width = 1;
    double left = 1;

    eventos.forEach((ev) {
      if (event.collidesWith(ev)) {
        list.add(ev);
      }
    });

    if (list.length > 0) {
      int index = list.reversed.toList().indexOf(event);
      width = (MediaQuery.of(context).size.width - 76) / (list.length);
      left = 76 +
          (index / (list.length) * (MediaQuery.of(context).size.width - 76));
    } else {
      width = MediaQuery.of(context).size.width - 76;
      left = 76;
    }

    return {"left": left, "width": width};
  }

  Widget createWidget(Event event) => Positioned(
        top: _generatePositionCard(event.initialDate, isAllDay: event.allDay),
        left: calculateWidth(event, List.from(widget.events))['left'],
        width: calculateWidth(event, List.from(widget.events))['width'],
        child: Padding(
          padding: const EdgeInsets.only(left: 3.0, right: 3.0),
          child: GestureDetector(
            onTap: () {
              if (event.onEventTap != null) {
                event.onEventTap(event);
              }
            },
            child: _cardEvent(event),
          ),
        ),
      );

  Widget _cardEvent(Event ev, {double width}) {
    return Container(
      decoration: BoxDecoration(
        color: ev.color,
        border: Border.all(
          color: ev.borderColor == null ? Colors.transparent : ev.borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          bottomLeft: Radius.circular(2),
        ),
      ),
      height: _generateHeightCard(ev.finalDate, isAllDay: ev.allDay) -
          _generatePositionCard(ev.initialDate, isAllDay: ev.allDay),
      child: Text(
        "${ev.title} ${showHours(ev)}",
        style: ev.eventTitleStyle == null
            ? TextStyle(
                color: Colors.white,
              )
            : ev.eventTitleStyle,
      ),
    );
  }

  String showHours(Event ev) {
    if (ev.showHours != null && ev.showHours) {
      return '${DateFormat('HH:mm').format(ev.initialDate)} - ${DateFormat('HH:mm').format(ev.finalDate)}';
    }

    return '';
  }

  List<Widget> _buildListHours() {
    List<Widget> list = [];

    controller.listHour.forEach(
      (hour) {
        if ((hour['date'] as DateTime).minute == 00 ||
            (hour['date'] as DateTime).minute == 30) {
          list.add(
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      DateFormat('HH:mm').format(hour['date']),
                      style: TextStyle(
                          color: hour['selected']
                              ? widget.selectedColor == null
                                  ? Theme.of(context).primaryColor
                                  : widget.selectedColor
                              : widget.colorTimeLine == null
                                  ? Colors.grey[800]
                                  : widget.colorTimeLine),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                controller.setDateSelected(date: hour['date']);
                                if (widget.onTap != null) {
                                  widget.onTap(hour['date']);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.lerp(
                                    Border(
                                      top: BorderSide(
                                          width: hour['selected'] ? 2 : 1,
                                          color: hour['selected']
                                              ? widget.selectedColor == null
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : widget.selectedColor
                                              : widget.colorTimeLine == null
                                                  ? Colors.grey
                                                  : widget.colorTimeLine),
                                    ),
                                    Border(
                                      top: BorderSide(
                                          width: hour['selected'] ? 2 : 1,
                                          color: hour['selected']
                                              ? widget.selectedColor == null
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : widget.selectedColor
                                              : widget.colorTimeLine == null
                                                  ? Colors.grey
                                                  : widget.colorTimeLine),
                                    ),
                                    1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );

    return list;
  }
}
