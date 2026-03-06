import 'package:flutter/material.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';


class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: compactDimens.extraLarge,
        leading: Padding(
          padding: EdgeInsets.only(left: compactDimens.small3),
          child: Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/MountainDark.png'
                : 'assets/images/Mountain.png',
            height: compactDimens.medium2,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, size: compactDimens.medium1),
          ),
        ],
      ),
      body: Center(
        child: Text("This is event screen"),
      ),
    );
  }
}
