import 'dart:io';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';
import '../models/schedule.dart';
import 'add_schedule_page.dart';
import 'schedule_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<Schedule>> _events;
  late List<Schedule> _selectedEvents;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final schedules = await DBHelper().getSchedules();
    setState(() {
      _events = _groupSchedulesByDate(schedules);
      _selectedEvents = _getEventsForDay(_selectedDay);
    });
  }

  Map<DateTime, List<Schedule>> _groupSchedulesByDate(
      List<Schedule> schedules) {
    Map<DateTime, List<Schedule>> data = {};
    for (var schedule in schedules) {
      DateTime date = DateTime(schedule.startDate.year,
              schedule.startDate.month, schedule.startDate.day)
          .toLocal();
      if (data[date] == null) data[date] = [];
      data[date]!.add(schedule);
    }
    return data;
  }

  List<Schedule> _getEventsForDay(DateTime day) {
    DateTime date = DateTime(day.year, day.month, day.day).toLocal();
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day)
              .toLocal();
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(_selectedDay);
    });
  }

  void _deleteSchedule(Schedule schedule) async {
    if (schedule.id != null) {
      await DBHelper().deleteSchedule(schedule.id!);
      _fetchSchedules(); // Refresh the schedules after deletion
    } else {
      // Handle the case where schedule.id is null
      print('Schedule ID is null');
    }
  }

  void _updateSchedule(Schedule newSchedule) {
    _fetchSchedules(); // Refresh the schedules after editing
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          TableCalendar<Schedule>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: _onDaySelected,
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM(locale).format(date),
              titleTextStyle: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(child: Text('No events for this day.'))
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      final eventColor = Color(event.color);
                      final textColor = _getContrastingTextColor(eventColor);

                      return GestureDetector(
                        onTap: () async {
                          final editedSchedule =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ScheduleDetailPage(
                                schedule: event,
                                onDelete: () {
                                  _deleteSchedule(event); // Delete the event
                                },
                                onEdit: _updateSchedule,
                              ),
                            ),
                          );

                          if (editedSchedule != null) {
                            _updateSchedule(editedSchedule);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  width: 20.0), // Add padding to the left
                              Column(
                                children: [
                                  Text(
                                    DateFormat.E().format(event.startDate),
                                    style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: eventColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      DateFormat.d().format(event.startDate),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20.0),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      if (event.imagePath1.isNotEmpty)
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: FileImage(
                                                  File(event.imagePath1)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      if (event.imagePath1.isNotEmpty)
                                        const SizedBox(width: 20.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 2),
                                            Text(
                                              event.title,
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${DateFormat.jm().format(event.startDate)} - ${DateFormat.jm().format(event.endDate)}',
                                              style: const TextStyle(
                                                  fontSize: 14.0,
                                                  letterSpacing: 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddSchedulePage(initialDate: _selectedDay),
            ),
          );
          _fetchSchedules();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
