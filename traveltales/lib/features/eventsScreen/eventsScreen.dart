import 'package:flutter/material.dart';
import '../../api/api.dart'; // make sure this is the correct path for getDestination()

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  @override
  void initState() {
    super.initState();
    logDestination(); // call when screen loads
  }
  Future<void> logDestination() async {
    try {
      final Map<String, dynamic>? destination =
      await getDestination(48); // pass valid destinationId

      if (destination != null) {
        print(destination['place_name']); // ✅ works
      } else {
        print("Destination is null");
      }
    } catch (e) {
      print("Error fetching destination: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("This is event screen"),
      ),
    );
  }
}
