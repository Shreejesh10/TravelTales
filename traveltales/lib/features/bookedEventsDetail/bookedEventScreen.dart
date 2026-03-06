import 'package:flutter/material.dart';

class BookedEventsScreen extends StatefulWidget {
  const BookedEventsScreen({super.key});

  @override
  State<BookedEventsScreen> createState() => _BookedEventsScreenState();
}

class _BookedEventsScreenState extends State<BookedEventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Booked Event Page"),
      ),
    );
  }
}
