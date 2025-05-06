import 'package:flutter/material.dart';
import 'package:mudepocflutter/models/event.dart';
import 'package:mudepocflutter/db/event_database.dart';
import 'event_details_screen.dart';
import 'event_form_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await EventDatabase().getAllEvents();
    setState(() {
      _events = events;
    });
  }

  void _navigateToForm({Event? event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(event: event),
      ),
    );

    if (result == true) {
      _loadEvents(); // recarrega ao salvar
    }
  }

  void _deleteEvent(int id) async {
    await EventDatabase().deleteEvent(id);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text('${event.date} – ${event.time}\n${event.location}'),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(event: event),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToForm(event: event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEvent(event.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}